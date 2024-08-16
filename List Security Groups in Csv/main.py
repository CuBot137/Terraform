import boto3
import pandas as pd
from botocore.exceptions import ClientError

# Initialize the EC2 client
ec2 = boto3.client('ec2', region_name='eu-west-1')

try:
    # Call describe_security_groups to retrieve all security groups
    response = ec2.describe_security_groups()

    # Prepare lists to hold the data for the DataFrame
    data = []

    # Process each security group
    for sg in response['SecurityGroups']:
        group_name = sg.get('GroupName')
        group_id = sg.get('GroupId')
        description = sg.get('Description')
        vpc_id = sg.get('VpcId')

        # Process Ingress Rules (Inbound)
        for rule in sg.get('IpPermissions', []):
            protocol = rule.get('IpProtocol')
            from_port = rule.get('FromPort')
            to_port = rule.get('ToPort')

            for ip_range in rule.get('IpRanges', []):
                cidr_ip = ip_range.get('CidrIp')
                data.append([group_name, group_id, description, vpc_id, 'Inbound', protocol, from_port, to_port, cidr_ip])

        # Process Egress Rules (Outbound)
        for rule in sg.get('IpPermissionsEgress', []):
            protocol = rule.get('IpProtocol')
            from_port = rule.get('FromPort')
            to_port = rule.get('ToPort')

            for ip_range in rule.get('IpRanges', []):
                cidr_ip = ip_range.get('CidrIp')
                data.append([group_name, group_id, description, vpc_id, 'Outbound', protocol, from_port, to_port, cidr_ip])

    # Create a DataFrame from the data
    df = pd.DataFrame(data, columns=['GroupName', 'GroupId', 'Description', 'VpcId', 'Direction', 'IpProtocol', 'FromPort', 'ToPort', 'CidrIp'])

    # Save the DataFrame to a CSV file
    df.to_csv('security_groups.csv', index=False)

    print("Security group data has been saved to security_groups.csv")

except ClientError as e:
    print(f"An error occurred: {e}")