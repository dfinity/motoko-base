# Contributing

Thank you for your interest in contributing to the Motoko library ecosystem.
By participating in this project, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md).

As a member of the community, you are invited and encouraged to contribute by submitting issues, offering suggestions for improvements, adding review comments to existing pull requests, or creating new pull requests to fix issues.

## Contents of this repository

This repository contains source code for the Motoko base library. The base library forms the standard library for the Motoko programming language and is expected to be used in almost all Motoko projects.

## Before you contribute

Before contributing, please take a few minutes to review these contributor guidelines.
The contributor guidelines are intended to make the contribution process easy and effective for everyone involved in addressing your issue, assessing changes, and finalizing your pull requests.

Before contributing, consider the following:

- If you want to report an issue, click **Issues**.

- If you have more general questions related to Motoko and its use, post a message to the [community forum](https://forum.dfinity.org/) or submit a [support request](mailto://support@dfinity.org).

- If you are reporting a bug, provide as much information about the problem as possible.

- If you want to contribute directly to this repository, typical fixes might include any of the following:

    - Fixes to resolve bugs or documentation errors
    - Code improvements
    - Feature requests

    Note that any contribution to this repository must be submitted in the form of a **pull request**.

- If you are creating a pull request, be sure that the pull request only implements one fix or suggestion.

If you are new to working with GitHub repositories and creating pull requests, consider exploring [First Contributions](https://github.com/firstcontributions/first-contributions) or [How to Contribute to an Open Source Project on GitHub](https://egghead.io/courses/how-to-contribute-to-an-open-source-project-on-github).

# How to make a contribution

Depending on the type of contribution you want to make, you might follow different workflows.

This section describes the most common workflow scenarios:

- Reporting an issue
- Submitting a pull request

### Reporting an issue

To open a new issue:

1. Click **Issues**.

1. Click **New Issue**.

1. Click **Open a blank issue**.

1. Type a title and description, then click **Submit new issue**.

    Be as clear and descriptive as possible.

    For any problem, describe it in detail, including details about the crate, the version of the code you are using, the results you expected, and how the actual results differed from your expectations.

### Submitting a pull request

If you want to submit a pull request to fix an issue or add a feature, here's a summary of what you need to do:

1. Make sure you have a GitHub account, an internet connection, and access to a terminal shell or GitHub Desktop application for running commands.

1. Navigate to the DFINITY public repository in a web browser.

1. Click **Fork** to create a copy the repository associated with the issue you want to address under your GitHub account or organization name.

1. Clone the repository to your local machine.

1. Create a new branch for your fix by running a command similar to the following:

    ```bash
    git checkout -b my-branch-name-here
    ```

1. Open the file you want to fix in a text editor and make the appropriate changes for the issue you are trying to address.

1. Add the file contents of the changed files to the index `git` uses to manage the state of the project by running a command similar to the following:

    ```bash
    git add path-to-changed-file
    ```
1. Commit your changes to store the contents you added to the index along with a descriptive message by running a command similar to the following:

    ```bash
    git commit -m "Description of the fix being committed."
    ```

1. Push the changes to the remote repository by running a command similar to the following:

    ```bash
    git push origin my-branch-name-here
    ```

1. Create a new pull request for the branch you pushed to the upstream GitHub repository.

    Provide a title that includes a short description of the changes made.

1. Wait for the pull request to be reviewed.

1. Make changes to the pull request, if requested.

1. Celebrate your success after your pull request is merged!
