#!/usr/bin/env bash


SETUP="SETUP:
    aws-vault add {AWS_ACCOUNT_IAM_ALIAS}-{console}
    where firefox container_name = AWS_ACCOUNT_IAM_ALIAS without the '-console'
"
USAGE="USAGE: bash script_name.sh link_set"


transform_url() {
    local container_name="$1"
    local URL="$2"
    # ENCODED_URL="${URL//&/%26}"
    ENCODED_URL="$URL"
    URI_HANDLER="ext+container:name=${container_name}&url=${ENCODED_URL}"
    echo "$URI_HANDLER"
}

open_windows(){

    # key to links.json file
    local link_set="$1"
    # container_name="$(cat ~/.aws/config | grep profile | tr -d '[]' | awk '{print $NF}' | rofi -dmenu -p "Choose AWS account:")"
    local chosen_aws_vault_credential
    local AWS_ACCOUNT_IAM_ALIAS
    local LOGIN_URL
    chosen_aws_vault_credential="$(aws-vault list | awk '/\w+\s+\w+-console/  {if (NR>1) {print $2}}' | rofi -dmenu -p "Choose AWS account:")"
    # delete console from end of string
    AWS_ACCOUNT_IAM_ALIAS="${chosen_aws_vault_credential/-console}"
    echo "$AWS_ACCOUNT_IAM_ALIAS ======="

    echo "$chosen_aws_vault_credential"
    # aws-vault login "$chosen_aws_vault_credential"
    LOGIN_URL=$(aws-vault login --stdout "$chosen_aws_vault_credential")
    [[ $? != 0 ]] && echo "${LOGIN_URL}" && return

    local count
    local url
    count=0
    while IFS= read -r url; do
        echo "... $count $url ..."
        if [ "$count" -eq 0 ]; then
            firefox --new-window "$(transform_url "$AWS_ACCOUNT_IAM_ALIAS" "$url")"
        else
            firefox --new-tab "$(transform_url "$AWS_ACCOUNT_IAM_ALIAS" "$url")"
        fi
        count=$((count + 1))

    # read links for this aws account from config file
    done <<< "$(cat links.json | jq ".$link_set[]" | tr -d '"')"

}

[ $# -eq 1 ] && open_windows "$1" || echo -e "wrong num args\n$USAGE"

