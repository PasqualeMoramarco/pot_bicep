# POT BICEP

## Description
This project serves as a POT for utilizing Bicep, a domain-specific language (DSL) for deploying Azure resources declaratively. The repository showcases the basics of Bicep language syntax and structure, providing a foundation for creating Azure Resource Manager (ARM) templates more efficiently and with better readability.

## Features
* Bicep Proof of Concept: Demonstration of Bicep language in action for deploying Azure resources.
* Readability: Improved readability and maintainability compared to traditional ARM templates.
* Flexibility: Easily extensible and customizable for various Azure resource scenarios.

## Getting Started
Prerequisites
Before you begin, ensure you have met the following requirements:

Azure CLI installed.
Bicep CLI installed.

## Installation
Clone the repository:

```
git clone https://github.com/PasqualeMoramarco/pot_bicep.git
```

## Usage

* Deploy the Bicep file using the following command:
```
 az deployment group create --name lawpb-logdev --resource-group rg-pot-bicep-dev -f /resources/pot-bicep/rg-pot-bicep/law/common/template/main.bicep --parameters /resources/pot-bicep/rg-pot-bicep/law/common/parameters/common.json --parameters /resources/pot-bicep/rg-pot-bicep/law/common/parameters/dev.json  
 ```

* Verify the deployed resources in the Azure portal.
