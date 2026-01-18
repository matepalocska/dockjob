# DockJob (Enhanced Fork)

Job scheduler with a web UI - designed to run inside a container. This is an enhanced fork of the original [rmetcalf9/dockJob](https://github.com/rmetcalf9/dockJob) project with significant improvements for modern deployment and TrueNAS compatibility.

**🚀 This fork includes major enhancements for production use, TrueNAS integration, and modern Python dependencies.**

I put images for this project into the [Docker hub](https://hub.docker.com/r/matepalocska/dockjob/)

## 🆕 What's New in This Fork

### Major Enhancements Since Fork

#### 🔧 **Modern Dependencies & Security**
- **Updated all Python dependencies** to latest stable versions (Jan 2026)
  - Flask: 2.0.3 → 3.1.2 (major version upgrade)
  - SQLAlchemy: 1.4.41 → 2.0.44 (major version upgrade)
  - Pandas: 1.3.5 → 2.3.3 (major version upgrade) 
  - NumPy: 1.21.6 → 2.2.6 (major version upgrade)
  - And many more critical security and compatibility updates
- **Resolved dependency conflicts** between baseapp packages and core dependencies
- **Enhanced security** with updated cryptographic libraries

#### 🏠 **TrueNAS Integration**
- **Native TrueNAS support** with pre-configured custom app YAML
- **Apps user compatibility** (UID 568) for proper file permissions
- **Volume mounting** optimized for TrueNAS datasets
- **Permission management** automatic setup for TrueNAS environments
- **Professional app logo** and catalog metadata for TrueNAS app store

#### 🐳 **Container & Deployment Improvements**
- **Multi-platform builds** (AMD64/ARM64) with automated Docker Hub publishing
- **Optimized Dockerfile** with better layer caching and security
- **User management** switched from `dockjobuser` to `apps` (UID 568)
- **Automated permission fixing** on container startup
- **Improved health checks** and container lifecycle management

#### 🛠 **Build System Enhancements**
- **Automated build pipeline** with version management
- **Multi-platform Docker builds** using buildx
- **Automated Docker Hub publishing** with proper tagging
- **Development environment** improvements with better scripts
- **Version management** integrated into build process

#### 📦 **Configuration & Deployment**
- **Environment variable templates** for easy configuration
- **Docker Compose examples** updated for modern Docker
- **TrueNAS custom app configuration** with detailed setup guide
- **Generic configuration templates** for easy customization
- **Comprehensive documentation** for deployment scenarios

#### ⏱️ **Enhanced Job Control & Execution**
- **Configurable execution timeouts** - Set custom timeout per job (0 = unlimited, default = 15 seconds)
- **Improved job validation** with proper input validation for all job parameters
- **Enhanced job execution** with per-job timeout enforcement instead of hardcoded limits
- **Better error handling** for job creation and execution with detailed validation messages
- **UI improvements** for job creation with timeout configuration in the web interface

#### 🎨 **UI & Branding**
- **Custom logo** designed for TrueNAS catalog integration
- **Professional branding** with SVG and PNG logo variants
- **Catalog metadata** for app store presentation
- **Screenshots** updated for current interface

### 🔄 **Breaking Changes from Original**
- **User changed** from `dockjobuser` to `apps` (affects volume permissions)
- **Updated Python dependencies** may require testing of existing jobs
- **Container runs as root** by default (for JobExecutor compatibility) but uses apps user for job execution
- **Environment variables** updated to reflect new user/group names

---

# Features

![Dockjob Dashboard Screen](./screenshots/DOCKJOB_DASHBOARD.png)
[See more](./screenshots/README.md)

 - Runs commands based on a schedule
 - 'Run now' button as well as scheduled run
 - **Configurable execution timeouts** - Set custom timeout per job (0 = unlimited, >0 = custom timeout in seconds)
 - Web App UI developed which connects to api.
 - Works in any web context
 - Works from any port
 - Will run any command inside the container - but I am really focused to run wget commands. This makes use of security provided by docker networking.
 - Doesn't do https or security itself - [Kong](https://konghq.com/) will also be deployed to the stack to provide this
 - Main interface is a simple json api
 - Keeps logs of recent runs of jobs.
 - INITIALLY won't use a data store as a backend. On restart will lose all data, configured jobs, logs, etc.

## 🚀 Quick Start

### Basic Docker Run
⚠️ **Note**: This fork uses `matepalocska/dockjob` instead of the original `metcarob/dockjob` image.

```bash
docker run -d -p 80:80 \
  -e APIAPP_APIURL='http://localhost:80/api' \
  -e APIAPP_APIDOCSURL='http://localhost:80/apidocs' \
  matepalocska/dockjob:latest
```

Visit http://localhost/frontend

### TrueNAS Custom App
This fork is optimized for TrueNAS deployment:

1. **Copy the [TrueNAS configuration](./truenas-custom-app.yaml.example)**
2. **Customize the placeholders** (YOUR_USERNAME, YOUR_TRUENAS_HOST, etc.)
3. **Add as custom app** in TrueNAS with the provided YAML
4. **Mount your datasets** for persistent storage

See the [TrueNAS deployment guide](./truenas-custom-app.yaml.example) for detailed setup instructions.

### Docker Compose
For production deployments, see [compose examples](./composeExamples/README.md) for robust deployment configurations with authentication and HTTPS support.

---

# Getting started - Running DockJob to check it out...

On a machine with docker installed run the following command:
````
docker run -d -p 80:80 -e APIAPP_APIURL='http://localhost:80/api' -e'APIAPP_APIDOCSURL=http://localhost:80/apidocs' matepalocska/dockjob:latest
````

Visit http://localhost/frontend

In this setup there is no user authentication or https. To run with these see [compose examples](./composeExamples/README.md) for information on a more robust way to deploy it and [Environment Variables](ENVVARIABLES.md) for documentation of possible environment variables that can be used as settings.

 

# Contributing & Development

## 🍴 Fork Information

This is an **enhanced fork** of the original [rmetcalf9/dockJob](https://github.com/rmetcalf9/dockJob) project. 

**Upstream Repository**: https://github.com/rmetcalf9/dockJob  
**This Fork**: https://github.com/matepalocska/dockjob  
**Docker Images**: https://hub.docker.com/r/matepalocska/dockjob/

### Why This Fork?

The original project was excellent but needed modernization for current deployment practices:
- **Updated dependencies** for security and compatibility
- **TrueNAS integration** for home lab deployments  
- **Modern container practices** with multi-platform builds
- **Enhanced documentation** and deployment guides
- **Production-ready configurations** with proper user management

### Contributing

If you have any ideas or improvements, please:
1. **Open an issue** to discuss your idea
2. **Fork this repository** for your changes
3. **Submit a pull request** with your improvements
4. **Consider contributing back** to the upstream project if applicable

## 🏗 Development & Architecture

A high level [description of the architecture is here](ARCHITECTURE.md).

The project is organized logically into sub directories with README.md files explaining each component:

 | Component         | Location                  | Description                                                                                                                                              |
 |-------------------|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
 | [Application](./app/README.md)       | ./app                     | DockJob Application that runs continuously. This provides a RESTFUL API and executes the Jobs as scheduled, or on receipt of an API call.                 |
 | [Frontend](./frontend/README.md)       | ./frontend             | Quasar-based web application that provides the graphical UI and communicates with the API.                                                      |
 | [Integration tests](./integrationtests/README.md) | ./integrationtests        | Set of tests which test both the Application and Frontend                                                                                             |
 | [Build Process](./dockerImageBuildProcess/README.md)     | ./dockerImageBuildProcess | Bash scripts which run all tests (both unit and integration) and then versions and builds the docker image                                               |
 | [Compose Examples](./composeExamples/README.md)  | ./composeExamples         | The image is designed to work in a docker swarm with Kong as a reverse proxy to provide security. This directory provides some examples of deploying it. |
 | [TrueNAS Integration](./truenas-custom-app.yaml.example)  | ./truenas-custom-app.yaml.example         | TrueNAS custom app configuration with detailed setup instructions for home lab deployments. |

## 🔄 Enhanced Release Process

This fork includes an improved release process:

### Automated Building
- **Multi-platform builds** (AMD64/ARM64) using Docker buildx
- **Automated Docker Hub publishing** with proper version tagging
- **Dependency updates** with conflict resolution
- **Version management** integrated into build scripts

### Manual Release Steps
1. **Run the enhanced [build process](./build-and-push-dockerhub.sh)** to create and push images
2. **Test the container** with both development and TrueNAS configurations
3. **Update VERSION** file and commit changes
4. **Create GitHub release** with changelog
5. **Update Docker Hub** description with new features

### Development Environment
```bash
# Clone the repository
git clone https://github.com/matepalocska/dockjob.git
cd dockjob

# Set up development environment
./app/run_app_developer.sh

# Build and test
./build.sh

# Build and push to Docker Hub (requires authentication)
./build-and-push-dockerhub.sh
```

---

## 📋 Legacy Release Process (Original)

_This section preserved from the original project for reference:_

At the moment I have a multi stage build so it wasn't possible to use TravisCI to make an automatic build process.

To release dockjob I:
 - Run the [build process](./dockerImageBuildProcess/README.md) to create an image on my local machine
 - Make sure I remember to stop the dev server instances before testing the container
 - Launch the image with a docker run command (Above) and make sure it starts and the logs display correct version number
 - Go into compose examples and run https basic auth example and make sure I can log in to the application (A temp version of the compose file must be produced with hard coded version number as the latest tag will not point to the right version even though docker images shows that it does.)
 - When testing use incognito mode as the webapp is cached by browsers.
 - Rename milestone
 - Update RELEASE.md (pointing at the milestone)
 - Run docker login and log in to my docker hub account
 - Run docker push metcarob/dockjob:VERSION (Replace VERSION with version number that was just built)
 - Run docker push metcarob/dockjob:latest
 - Create new next milestone
 - Commit changes to git

---

# 📦 Related Projects

## Core Dependencies
 - [Kong](https://konghq.com/) - API Gateway for security and routing
 - [Konga](https://github.com/pantsel/konga) - Kong Admin UI
 - [Quasar Framework](https://quasar.dev/) - Vue.js framework for the frontend
 - [baseapp_for_restapi_backend_with_swagger](https://github.com/rmetcalf9/baseapp_for_restapi_backend_with_swagger) - Shared utilities library for API backends

## TrueNAS Integration
 - [TrueNAS SCALE](https://www.truenas.com/truenas-scale/) - Open source hyperconverged infrastructure
 - [TrueNAS Custom Apps](https://www.truenas.com/docs/scale/scaletutorials/apps/customapp/) - Custom application deployment system

## Development Tools
 - [Docker Buildx](https://docs.docker.com/buildx/) - Multi-platform container builds
 - [uWSGI](https://uwsgi-docs.readthedocs.io/) - Python WSGI HTTP Server
 - [Nginx](https://nginx.org/) - Reverse proxy and static file serving

---

# 🙏 Acknowledgments

## Original Project
**Huge thanks** to [rmetcalf9](https://github.com/rmetcalf9) for creating the original [dockJob](https://github.com/rmetcalf9/dockJob) project. This fork builds upon their excellent foundation and architectural decisions.

## Fork Enhancements
This enhanced fork was created to address modern deployment needs, particularly for:
- **Home lab enthusiasts** using TrueNAS SCALE
- **Production environments** requiring updated dependencies
- **Multi-platform deployments** (AMD64/ARM64)
- **Container security** best practices

## Contributors
- **Original Author**: [rmetcalf9](https://github.com/rmetcalf9) - Created the foundational architecture and core functionality
- **Fork Maintainer**: [matepalocska](https://github.com/matepalocska) - Enhanced dependencies, TrueNAS integration, and modern deployment practices

---

**📞 Support**: For issues with this fork, please use the [GitHub Issues](https://github.com/matepalocska/dockjob/issues) on this repository.  
**💡 Original Project**: For general questions about the core architecture, see the [upstream repository](https://github.com/rmetcalf9/dockJob).
