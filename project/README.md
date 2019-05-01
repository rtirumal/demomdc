# project folder

## Why Does This Folder Exist and How is it Used?

Initially there was a situation in which we needed to create a unique version of the `ecr-repos` package in order to start migrating older projects into this repo incrementally. We do **NOT** suggest using this folder as a practice. Packages here are  temporary in nature. They are intended to not be needed for a specific project as migrations to standard packages are completed.

### Do I need to create a project specific package for the work I'm doing?

**Consider this example:**

- The `projects/eqp/ecr-repos` package exists because the EQP project code we were migrating used policys attached to the repos themselves to control access. Our existing package assumes that iam policies are used for access control per best practice. Once we change the EQP project to use iam roles instead of policies attached to the repo itself, we would be able to remove this project specific version of the ecr-repos package.

**The options for this case were:**

1. Create a new folder convention in this package repo to store these unique cases. e.g. `project/project-name/package`
2. Create a unique repo in each of these case that are project specific and version project specific modules in their unique repos. (e.g. like we did with amazon sales channel project)

> _**Please Understand**_: The way we use this folder may change. For example we may determine in a migration scenario it is best to keep a projects specific packages in their own versioned repository.

For questions or feedback email: grp-magento-devops@adobe.com
