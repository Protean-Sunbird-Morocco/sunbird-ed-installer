#!/bin/bash
set -euo pipefail

echo -e "\nPlease ensure you have updated all the mandatory variables as mentioned in the documentation."
echo "The installation will fail if any of the mandatory variables are missing."
echo "Press Enter to continue..."
read -r

RELEASE="release700"
environment=dev

function backup_configs() {
    echo -e "\nUsing existing config files if they exist"
    
    # Ensure the Kube config directory exists
    mkdir -p ~/.kube
    
    # Ensure the rclone config directory exists
    mkdir -p ~/.config/rclone
    
    # Set the KUBECONFIG environment variable to use the existing config file
    export KUBECONFIG=~/.kube/config
}

function create_tf_backend() {
    echo -e "Creating terraform state backend"
    bash create_tf_backend.sh "$environment"
}

function create_tf_resources() {
    source tf.sh
    echo -e "\nCreating resources on GCP"
    terragrunt run-all apply --terragrunt-non-interactive
    # Check if the Kube config file exists before changing permissions
    if [ -f ~/.kube/config ]; then
        chmod 600 ~/.kube/config
    else
        echo "Warning: Kubernetes config file does not exist at ~/.kube/config. Skipping permission change."
    fi
}

function certificate_keys() {
    # Generate private and public keys using openssl
    echo "Creation of RSA keys for certificate signing"
    openssl genrsa -out ../terraform/gcp/$environment/certkey.pem
    openssl rsa -in ../terraform/gcp/$environment/certkey.pem -pubout -out ../terraform/gcp/$environment/certpubkey.pem
    CERTPRIVATEKEY=$(sed 's/KEY-----/KEY-----\\n/g' ../terraform/gcp/$environment/certkey.pem | sed 's/-----END/\\n-----END/g' | awk '{printf("%s",$0)}')
    echo "CERTIFICATE_PRIVATE_KEY: \"$CERTPRIVATEKEY\"" >> ../terraform/gcp/$environment/global-values.yaml
    awk '{if($0 !~ /END/)  printf "%s\\r\\n",$0;} END{printf "-----END PUBLIC KEY-----"}' ../terraform/gcp/$environment/certpubkey.pem | awk '{print "CERTIFICATE_PUBLIC_KEY: \""$0"\""}' >> ../terraform/gcp/$environment/global-values.yaml
    echo "CERTIFICATESIGN_PRIVATE_KEY: \"$CERTPRIVATEKEY\"" >> ../terraform/gcp/$environment/global-values.yaml
    awk '{if($0 !~ /END/)  printf "%s\\r\\n",$0;} END{printf "-----END PUBLIC KEY-----"}' ../terraform/gcp/$environment/certpubkey.pem | awk '{print "CERTIFICATESIGN_PUBLIC_KEY: \""$0"\""}' >> ../terraform/gcp/$environment/global-values.yaml
}

function certificate_config() {
    # Check if the key is already present in RC 
    echo "Configuring Certificate keys"
    kubectl -n sunbird exec deploy/nodebb -- apt update -y
    kubectl -n sunbird exec deploy/nodebb -- apt install jq -y
    CERTKEY=$(kubectl -n sunbird exec deploy/nodebb -- curl --location --request POST 'http://registry-service:8081/api/v1/PublicKey/search' --header 'Content-Type: application/json' --data-raw '{ "filters": {}}' | jq '.[] | .value')
    
    # Inject cert keys to the service if it's not available 
    if [ -z "$CERTKEY" ]; then
        echo "Certificate RSA public key not available"
        CERTPUBKEY=$(awk -F'"' '/CERTIFICATE_PUBLIC_KEY/{print $2}' global-values.yaml)
        curl_data="curl --location --request POST 'http://registry-service:8081/api/v1/PublicKey' --header 'Content-Type: application/json' --data-raw '{\"value\":\"$CERTPUBKEY\"}'"
        echo "kubectl -n sunbird exec deploy/nodebb -- $curl_data" | sh -
    fi
}

function install_component() {
    kubectl create configmap keycloak-key -n sunbird 2>/dev/null || true
    local current_directory="$(pwd)"
    if [ "$(basename "$current_directory")" != "helmcharts" ]; then
        cd ../../../helmcharts 2>/dev/null || true
    fi
    local component="$1"
    kubectl create namespace sunbird 2>/dev/null || true
    echo -e "\nInstalling $component"
    local ed_values_flag=""
    if [ -f "$component/ed-values.yaml" ]; then
        ed_values_flag="-f $component/ed-values.yaml --wait --wait-for-jobs"
    fi

    # Generate the key pair required for the certificate template
    if [ "$component" = "learnbb" ]; then
        if kubectl get job keycloak-kids-keys -n sunbird >/dev/null 2>&1; then
            echo "Deleting existing job keycloak-kids-keys..."
            kubectl delete job keycloak-kids-keys -n sunbird
        fi

        if [ -f "certkey.pem" ] && [ -f "certpubkey.pem" ]; then
            echo "Certificate keys are already created. Skipping the keys creation..."
        else
            certificate_keys
        fi
    fi

    helm upgrade --install "$component" "$component" --namespace sunbird -f "$component/values.yaml" \
        $ed_values_flag \
        -f "../terraform/gcp/$environment/global-values.yaml" \
        -f "../terraform/gcp/$environment/global-values-jwt-tokens.yaml" \
        -f "../terraform/gcp/$environment/global-values-rsa-keys.yaml" \
        -f "../terraform/gcp/$environment/global-cloud-values.yaml" --timeout 30m --debug
}

function install_helm_components() {
    components=("monitoring" "edbb" "learnbb" "knowledgebb" "obsrvbb" "inquirybb")
    for component in "${components[@]}"; do
        install_component "$component"
    done
}

function dns_mapping() {
    domain_name=$(kubectl get cm -n sunbird report-env -ojsonpath='{.data.SUNBIRD_ENV}')
    PUBLIC_IP=$(kubectl get svc -n sunbird nginx-public-ingress -ojsonpath='{.status.loadBalancer.ingress[0].ip}')

    local timeout=$((SECONDS + 1200))
    local check_interval=10

    echo -e "\nAdd/update your DNS mapping for your domain by adding an A record to this IP: ${PUBLIC_IP}. The script will wait for 20 minutes"

    while [ $SECONDS -lt $timeout ]; do
        current_ip=$(nslookup "$domain_name" | grep -E -o 'Address: [0-9.]+' | awk '{print $2}')

        if [ "$current_ip" == "$PUBLIC_IP" ]; then
            echo -e "\nDNS mapping has propagated successfully."
            return
        fi
        echo "DNS mapping is still propagating. Retrying in $check_interval seconds..."
        sleep $check_interval
    done

    echo "Timed out after 20 minutes. DNS mapping may not have propagated successfully. Rerun the following staging post DNS mapping propagation."
    echo "./install.sh dns_mapping"
    echo "./install.sh generate_postman_env"
    echo "./install.sh run_post_install"
}

function generate_postman_env() {
    local current_directory="$(pwd)"
    if [ "$(basename "$current_directory")" != "$environment" ]; then
        cd ../terraform/gcp/$environment 2>/dev/null || true
    fi
    domain_name=$(kubectl get cm -n sunbird report-env -ojsonpath='{.data.SUNBIRD_ENV}') 
    api_key=$(kubectl get cm -n sunbird player-env -ojsonpath='{.data.sunbird_api_auth_token}')
    keycloak_secret=$(kubectl get cm -n sunbird player-env -ojsonpath='{.data.sunbird_portal_session_secret}')
    keycloak_admin=$(kubectl get cm -n sunbird userorg-env -ojsonpath='{.data.sunbird_sso_username}')
    keycloak_password=$(kubectl get cm -n sunbird userorg-env -ojsonpath='{.data.sunbird_sso_password}')
    generated_uuid=$(uuidgen)
    temp_file=$(mktemp)
    cp postman.env.json "${temp_file}"
    sed -e "s|REPLACE_WITH_DOMAIN|${domain_name}|g" \
        -e "s|REPLACE_WITH_APIKEY|${api_key}|g" \
        -e "s|REPLACE_WITH_SECRET|${keycloak_secret}|g" \
        -e "s|REPLACE_WITH_KEYCLOAK_ADMIN|${keycloak_admin}|g" \
        -e "s|REPLACE_WITH_KEYCLOAK_PASSWORD|${keycloak_password}|g" \
        -e "s|REPLACE_WITH_UUID|${generated_uuid}|g" \
        "${temp_file}" > postman.env.json
    rm "${temp_file}"
    echo "Postman environment file has been generated successfully!"
}

function run_post_install() {
    echo "Running post-installation tasks..."
    echo "Please ensure that your application is up and running."
    echo "Starting post install..."
    cp ../../../postman-collection/collection${RELEASE}.json .
    postman collection run collection${RELEASE}.json --environment postman.env.json --delay-request 500 --bail --insecure
}

function restart_workloads_using_keys() {
    echo -e "\nRestart workloads using keycloak keys and wait for them to start..."
    kubectl rollout restart deployment -n sunbird neo4j knowledge-mw player content cert-registry groups userorg lms notification registry analytics
    kubectl rollout status deployment -n sunbird neo4j knowledge-mw player content cert-registry groups userorg lms notification registry analytics
    echo -e "\nWaiting for all pods to start"
}

# certificate_config
# generate_postman_env
# restart_workloads_using_keys
run_post_install

# backup_configs
# create_tf_backend
# create_tf_resources
# install_helm_components
# dns_mapping
# generate_postman_env
# run_post_install

echo "Installation completed successfully!"
