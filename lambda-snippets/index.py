import boto3
import json
import cfnresponse

def download_state_file(s3_client, bucket, key):
    s3_client.meta.client.download_file(bucket, key, '/tmp/terraform.tfstate')
    state_file = open('/tmp/terraform.tfstate')
    tf_state = json.load(state_file)
    return tf_state
    
def generate_outputs_response(outputs):
    response_data = {}
    for key in outputs.keys():
        response_data[key] = outputs[key]['value']
    return response_data

def handler(event, context):

    try:
        # Check if request is CREATE or UPDATE from Cfn Stack then outputs from
        # terraform state file will be read and if DELETE then return empty response
        if event["RequestType"] in ("Create", "Update"):
            
            # Create boto3 S3 resource
            s3 = boto3.resource('s3')

            # Get CFN Resource Properties from event
            cfn_properties = event["ResourceProperties"]
            bucket_name = cfn_properties.get('BucketName', None)
            state_key = cfn_properties.get('StateFileKey', None)
            specific_output = cfn_properties.get('SpecificOutput', None)

            if bucket_name and state_key:
                state_file = download_state_file(s3,bucket_name,state_key)
                response_data = {}

                # Check if specific_output parameter is present in Event payload coming from Cfn Resource
                # then return that specific output from the terraform state file else return all state file outputs
                if specific_output and specific_output != "":
                    response_data[specific_output] = state_file['outputs'][specific_output]['value']
                else:
                    response_data = generate_outputs_response(
                        state_file['outputs'])

                cfnresponse.send(
                    event, context, cfnresponse.SUCCESS, response_data)
            else:
                cfnresponse.send(event, context, cfnresponse.FAILED, {
                    "message": "Bucket or Key not provided"})

        elif event["RequestType"] == "Delete":
            cfnresponse.send(event, context, cfnresponse.SUCCESS, None)
        else:
            cfnresponse.send(event, context, cfnresponse.FAILED, None)

    except Exception as error:
        cfnresponse.send(event, context, cfnresponse.FAILED,
                         {"message": error})