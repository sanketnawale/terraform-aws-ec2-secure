package terraform.ec2.security

import rego.v1

# Deny instances with public IP
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    "create" in resource.change.actions
    
    resource.change.after.associate_public_ip_address == true
    
    msg := sprintf("EC2 instance '%s' should not have public IP for security", [resource.address])
}

# Require IMDSv2
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    "create" in resource.change.actions
    
    resource.change.after.metadata_options[0].http_tokens != "required"
    
    msg := sprintf("EC2 instance '%s' must enforce IMDSv2 (http_tokens = required)", [resource.address])
}

# Deny overly permissive SSH security groups  
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    "create" in resource.change.actions
    
    ingress_rule := resource.change.after.ingress[_]
    ingress_rule.from_port <= 22
    ingress_rule.to_port >= 22
    "0.0.0.0/0" in ingress_rule.cidr_blocks
    
    msg := sprintf("Security group '%s' allows SSH from anywhere (0.0.0.0/0)", [resource.address])
}
