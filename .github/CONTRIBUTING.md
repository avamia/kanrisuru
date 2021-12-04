# How to contribute
Thank you for your interest in contributing to the Kanrisuru project. We appreciate any volunteers that want to help improve, grow and sustain the Kanrisuru code base!

## Submitting a bug
*  Do not open up a GitHub issue if the bug is a security vulnerability with the Kanrisuru project, instead send an email to engineeering@avamia.com for any security realted issues.
*  Check if there's already an existing issue before submitting a [similar one](https://github.com/avamia/kanrisuru/issues).
*  If you can't find a similar issue [open a new one](https://github.com/avamia/kanrisuru/issues/new?assignees=&labels=&template=bug_report.md). Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

## Adding a core feature
*  We always welcome improving the core Kanrisuru project. If we are missing a core command available on most linux distros, this would be a place to add that type of functionality.
*  Other ideas like performance optimization, additional testing, and ease of use are great ways of improving the project.
*  If you want to create something outside of the core project, see the next section.

## Adding a new module
*  If you want to extent Kanrisuru beyond the underlying system code base or core module packages, the best way is to create a new gem, in the format of `kanrisuru-package`. 
*  This helps keep the core Kanrisuru package from too much bloat.
*  See our developer module section to see how to build a new Kanrisuru module.
