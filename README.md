# F5 BIG-IP Virtual Instance for Virtual Private Cloud using Custom Image

Use this template to create F5 BIG-IP virtual instances using a custom image from your IBM Cloud account in the IBM Cloud [VPC Gen2](https://cloud.ibm.com/vpc-ext/overview) using Terraform or IBM Cloud Schematics.  Schematics uses Terraform as the infrastructure-as-code engine.  With this template, you can create and manage infrastructure as a single unit. For more information how to use this template, see the IBM Cloud [Schematics documentation](https://cloud.ibm.com/docs/schematics).

_The F5 BIG-IP virtual instance supports the following at this time:_
- BYOL licensing.
- 1-NIC, standalone deployments.

## Support

F5 BIG-IP Virtual Edition - 
You can open a support case in the F5 WebSupport Portal at https://websupport.f5.com/, review additional F5 technical support documentation at https://support.f5.com/csp/article/K25327565 or contact F5 support directly (24x7x365):
- North America: 1-888-882-7535
- Outside North America: +800 11 ASK 4 F5 (800 1127 5435)

F5 support centers are strategically located for partners and customers in APAC, Japan, EMEA and North America. Regionally located support centers enable F5 to provide support in a number of languages through native-speaking engineers who are available when you are. An annual support contract may be purchased separately from F5 Technical Support Services at https://support.f5.com.

IBM Cloud IaaS Support
You're provided free technical support through the IBM Cloud™ community and Stack Overflow, which you can access from the Support Center. The level of support that you select determines the severity that you can assign to support cases and your level of access to the tools available in the Support Center. Choose a Basic, Advanced, or Premium support plan to customize your IBM Cloud™ support experience for your business needs. 

Learn more; https://www.ibm.com/cloud/support

## Prerequisites

- Must have access to [Gen 2 VPC](https://cloud.ibm.com/vpc-ext/network/vpcs).
- The given VPC must have at least 1 subnet to deploy the BIG-IP.  The lone subnet is for management and data traffic.  BIG-IP self-IPs will automatically be assigned to the subnet during initial boot.
- The BIG-IP custom image you wish to deploy is present in your list of images. run 'ibmcloud is images' to ensure the image you wish to deploy is available. 

## Costs

When you apply the template, the infrastructure resources that you create incur charges as follows. To clean up the resources, you can [delete your Schematics workspace or your instance](https://cloud.ibm.com/docs/schematics?topic=schematics-manage-lifecycle#destroy-resources). Removing the workspace or the instance cannot be undone. Make sure that you back up any data that you must keep before you start the deletion process.


* _VPC_: VPC charges are incurred for the infrastructure resources within the VPC, as well as network traffic for internet data transfer. For more information, see [Pricing for VPC](https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc).
* _VPC Custom Image_: VPC charges per custom image.
* _F5 BIG-IP Instances_: The price for your virtual server instances depends on the flavor of the instance, how many you provision, and how long the instances are run. For more information, see [Pricing for Virtual Servers for VPC](https://cloud.ibm.com/docs/infrastructure/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc#pricing-for-virtual-servers-for-vpc).

## Dependencies

Before you can apply the template in IBM Cloud, complete the following steps.


1.  Ensure that you have the following permissions in IBM Cloud Identity and Access Management:
    * `Manager` service access role for IBM Cloud Schematics
    * `Operator` platform role for VPC Infrastructure
2.  Ensure the following resources exist in your VPC Gen 2 environment
    - a VPC with 1 subnet
    - an SSH key, to ssh into your BIG-IP instance after deployment.
    - The custom image you wish to deploy is present in your account.

## Configuring your deployment values

When you select the F5 Virtual Edition tile (https://cloud.ibm.com/catalog/content/F5-1arm-offering) from the IBM Cloud catalog, you can set up your deployment variables from the `Create` page. Once the template is applied, IBM Cloud Schematics provisions the resources based on the values that were specified for the deployment variables.

### Required values
Fill in the following values, based on the steps that you completed before you began.

| Key | Default | Definition |
| --- | ------- | ---------- |
| `region` | null | The VPC Zone that you want your VPC virtual servers to be provisioned. To list available zones, run `ibmcloud is regions` |
| `ssh_key_name` | null | The name of your public SSH key to be used to login to the BIG-IP instance. Follow [Public SSH Key Doc](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-ssh-keys) for creating and managing ssh keys. |
| `instance_profile` | cx2-2x4 | The profile of compute CPU and memory resources to be used when provisioning the BIG-IP instance. To list available profiles, run `ibmcloud is instance-profiles`. |
| `tmos_image_name` | null | The name of the BIG-IP custom image you wish to deploy. To list available images, run `ibmcloud is images`.|
| `instance_name` | f5-ve-01 | The hostname of the BIG-IP instance to be provisioned.  Note that the system will add ".local" to this name. |
| `tmos_license_basekey` | null | The registration key to be used to license the BIG-IP. |
| `tmos_admin_password` | null | The password to be used for the admin account on the BIG-IP GUI.  If left blank, this will generate a random, 32 byte password. |
| `subnet_id` | null |The ID of the subnet where the BIG-IP interface will be deployed. Click on the subnet details in the VPC Subnet Listing to determine this value. | 

## Compute Profiles
| Profile Name | Throughput Max (per IBM) | Recommendations |
| ------------ | ------------------------ | --------------- |
| `cx2-2x4` | 4 Gbps | Ideal for Good or LTM license up to 1 Gbps (note that startup times may be extended due to memory utilization) |
| `cx2-4x8` | 8 Gbps | Ideal for Better, WAF and AWAF license up to 1 Gbps |
| `cx2-8x16` | 16 Gbps | Ideal for Best license up to 10 Gbps or Good/Better/WAF/AWAF throughputs above 1 Gbps |
| `cx2-16x32` | 64 GBps | Ideal for performance requiring 8 cores or more |


### Outputs
After you apply the template your VPC resources are successfully provisioned in IBM Cloud, you can review information such as the virtual server IP addresses and VPC identifiers in the Schematics log files, in the `Terraform SHOW and APPLY` section.

| Variable Name | Description | Sample Value |
| ------------- | ----------- | ------------ |
| `resource_name` | Name of the F5 BIG-IP instance | N/A |
| `resource_status` | Status of the F5 BIG-IP instance | `Running` or `Failed` |
| `VPC` | The VPC ID | `r134-7a9df886-xxxx-yyyy-zzzz-67c6dd202337` |
| `f5_shell_access` | SSH access to F5-BIGIP - `ssh://root@<Floating IP>` | `ssh://root@192.168.1.1` |
| `f5_admin_portal` | Web url to interact with F5-BIGIP admin portal - `https://<Floating IP>:8443` | `https://192.168.1.1:8443` |
| `f5_as3_url` | F5-BIGIP application services declarative interface - `https://<Floating IP>:8443/mgmt/shared/appsvcs/declare` | `https://192.168.1.1:8443/mgmt/shared/appsvcs/declare` |

## Notes

If there is a failure during F5 BIG-IP instance creation, the created resources must be destroyed before attempting to instantiate again. To destroy resources go to `Schematics -> Workspaces -> [Your Workspace] -> Actions -> Delete` to delete  all associated resources. <br/>
1. Do not modify or delete floating/public IPs used by the F5 BIG-IP instance.

# Post F5 BIG-IP Instance Spin-up

1. From the VPC list, confirm the F5 BIG-IP virtual instance is powered ON with a green button
2. If you created an admin password using the `tmos_admin_passsword` variable, open `https://<Floating IP>` and login using `admin` and the password you chose.
3. If you did not create an admin password, open an ssh terminal to your BIG-IP instance using the `<Floating IP>` created during bootup and the ssh key you assigned in the catalog.
4. On the terminal command line, enter `tmsh modify auth user admin password <new_password>`.  You may now go to step 2 to utilize the BIG-IP GUI.


