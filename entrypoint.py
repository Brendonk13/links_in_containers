import configparser
import subprocess

def extract_stdout(output):
    return output.stdout.decode("utf-8").strip()

def get_stdout(cmd):
    print(cmd)
    if stdout := extract_stdout(subprocess.run(cmd, shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)):
        print('out->', stdout)
        return stdout


#Read config.ini file
config_obj = configparser.ConfigParser()
config_obj.read("config.ini")
# bash open_all_aws.sh "link_set"
AWS_ACCOUNT_IAM_ALIAS  = get_stdout(r"aws-vault list | awk '/\w+\s+[\-a-zA-Z]+console/  {print $2}' | rev | cut -d- -f2- | rev | rofi -dmenu -p 'Choose AWS account:'")
print('alias, oy: ', AWS_ACCOUNT_IAM_ALIAS)
# chosen_aws_account = config_obj[AWS_ACCOUNT_IAM_ALIAS]
chosen_aws_account = config_obj['brendondev']
print(chosen_aws_account.values())

link_set = chosen_aws_account['link_set']
print(link_set, '===')
get_stdout(f'bash open_all_aws.sh {AWS_ACCOUNT_IAM_ALIAS} {link_set}')
