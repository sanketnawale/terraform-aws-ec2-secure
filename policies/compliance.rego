package terraform.compliance

import rego.v1

required_tags := ["Environment", "Project", "ManagedBy"]

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type in ["aws_instance", "aws_security_group"]
    "create" in resource.change.actions
    
    # Check both tags and tags_all (AWS provider default_tags)
    all_tags := object.union(
        object.get(resource.change.after, "tags", {}),
        object.get(resource.change.after, "tags_all", {})
    )
    
    missing_tags := [tag | 
        tag := required_tags[_]
        not all_tags[tag]
    ]
    count(missing_tags) > 0
    
    msg := sprintf("Resource '%s' missing required tags: %v", [resource.address, missing_tags])
}

# Enforce naming convention
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    "create" in resource.change.actions
    
    # Check both tags and tags_all for Name
    all_tags := object.union(
        object.get(resource.change.after, "tags", {}),
        object.get(resource.change.after, "tags_all", {})
    )
    
    name_tag := all_tags.Name
    not regex.match(`^[a-z][a-z0-9-]*-(dev|staging|prod)-[a-z]+$`, name_tag)
    
    msg := sprintf("EC2 instance '%s' name '%s' doesn't follow naming convention: <project>-<env>-<purpose>", [resource.address, name_tag])
}
