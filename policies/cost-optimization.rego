package terraform.cost

import rego.v1

# Allowed instance types for cost optimization
allowed_instance_types := ["t3.micro", "t3.small", "t2.micro", "t2.small"]

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    "create" in resource.change.actions
    
    not resource.change.after.instance_type in allowed_instance_types
    
    msg := sprintf("EC2 instance '%s' uses expensive instance type '%s'. Allowed: %v", 
        [resource.address, resource.change.after.instance_type, allowed_instance_types])
}

# Warn about large volumes
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance" 
    "create" in resource.change.actions
    
    resource.change.after.root_block_device[_].volume_size > 10
    
    msg := sprintf("EC2 instance '%s' has large root volume (%d GB). Consider if this size is necessary", 
        [resource.address, resource.change.after.root_block_device[_].volume_size])
}

