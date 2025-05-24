# 🚀 CrewAI Docker Starter

Run ANY CrewAI crew in Docker! No setup headaches, no virtual environment drama. Just pure AI magic in a box! ✨

> **⚠️ IMPORTANT**: Any changes to your crew code require rebuilding the Docker container!  
> Quick rebuild: `docker compose down && docker compose up -d --build`

## 🎯 What This Does

- 🐳 Runs your CrewAI crew in Docker with uv
- 🔄 Live code reloading for development 
- 📁 Saves outputs to your computer
- 🎮 Manual control - run crew when YOU want
- 📝 **Versioned outputs** - each run creates a new timestamped file!
- 🔍 **Built-in observability** with AgentOps tracing
- 🚫 No virtual environment management needed!
- ☁️ **AWS ECR deployment** - deploy to production with one command!

## 🏃‍♂️ Quick Start (3 Steps!)

### 1. 🔑 Set Your API Keys

Make sure your `crew/.env` file has your API keys:

**Required:**
```env
OPENAI_API_KEY=your_real_key_here
```

**Optional (for observability):**
```env
AGENTOPS_API_KEY=your_real_key_here
```

**🔍 Get your AgentOps API key**: [https://app.agentops.ai/settings/projects](https://app.agentops.ai/settings/projects)

### 2. 🏗️ Put Your Crew Code Here

Replace the `crew/` folder with YOUR crew:
- `crew/src/` - Your crew Python code
- `crew/pyproject.toml` - Your dependencies  
- `crew/uv.lock` - Your lock file (run `uv lock` to create)

### 3. 🎉 Start the Container!

```bash
docker compose up -d --build
```

Container is now running and ready! 🎊

**🔄 Remember**: After ANY code changes, you MUST rebuild with:
```bash
docker compose down && docker compose up -d --build
```

## 🎮 Running Your Crew

The container stays running but doesn't auto-execute. YOU control when to run:

```bash
# 🚀 Quick run (most common)
docker compose exec crew uv run python -c "from crew.main import run; run()"

# 🐚 Interactive mode (for exploring)
docker compose exec crew bash
# Then inside: uv run python -c "from crew.main import run; run()"

# 🧪 Other crew functions
docker compose exec crew uv run python -c "from crew.main import train; train()"
docker compose exec crew uv run python -c "from crew.main import test; test()"

# 🗑️ Clear all output files
docker compose exec crew uv run python -c "from crew.main import clear; clear()"
```

### 🔍 **Monitoring Your Crew:**
```bash
# Watch live logs
docker compose logs -f crew

# Check what's happening
docker compose ps

# Monitor resources
docker stats crew-app
```

## 🔍 Built-in Observability

**AgentOps Integration** - Get deep insights into your AI agents:

- 📊 **Real-time tracing** of agent execution
- 🧠 **Decision trees** and reasoning paths  
- ⏱️ **Performance metrics** and timing
- 🔄 **Multi-agent conversations** visualization

**View your traces**: [https://app.agentops.ai/traces](https://app.agentops.ai/traces)

### **Setup Observability:**
1. Get your API key: [https://app.agentops.ai/settings/projects](https://app.agentops.ai/settings/projects)
2. Add to `crew/.env`: `AGENTOPS_API_KEY=your_key_here`
3. Rebuild container: `docker compose down && docker compose up -d --build`

**Without AgentOps key**: Crew runs normally, just no observability dashboard.

## 📝 Versioned Outputs

Each crew run automatically creates a **timestamped output file**:
- 📅 Format: `crew-report_YYYY-MM-DD_HH-MM-SS.md`
- 🗂️ Saved to: `output/` directory 
- ✅ **Never overwritten** - each run is preserved!

**Example outputs:**
```
output/
├── crew-report_2025-05-24_20-23-40.md  # First run
├── crew-report_2025-05-24_20-24-37.md  # Second run
└── crew-report_2025-05-24_20-25-15.md  # Third run
```

Perfect for comparing different runs and tracking progress! 🎯

## 🔄 Code Changes & Rebuilding - READ THIS!

**🚨 CRITICAL**: Unlike regular development, Docker containers do NOT automatically pick up code changes. You MUST manually rebuild after every change to your crew code!

### **When You MUST Rebuild:**
- ✅ Modified any Python files in `crew/src/`
- ✅ Changed `crew/pyproject.toml` dependencies
- ✅ Updated configuration files (agents.yaml, tasks.yaml)
- ✅ Added/changed API keys in `.env`
- ✅ **ANY change to files in the `crew/` directory**

### **How to Rebuild:**
```bash
# Quick rebuild (one command) - RECOMMENDED
docker compose down && docker compose up -d --build

# Or step by step:
docker compose down              # Stop container
docker compose up -d --build    # Rebuild and start
```

### **Signs You Need to Rebuild:**
- 🚨 Your code changes aren't working
- 🚨 New dependencies aren't found
- 🚨 Environment variables aren't updating
- 🚨 Config changes aren't taking effect

**💡 Pro Tip**: Always rebuild when your agents aren't running to avoid interruption!

## 🛠️ Other Useful Commands

```bash
# Start/stop the container
docker compose up -d --build    # Start in background
docker compose down             # Stop everything

# See what's happening
docker compose logs -f crew

# Get a shell inside the container
docker compose exec crew bash

# Run Python directly with uv
docker compose exec crew uv run python

# Check container status
docker compose ps

# Clear old output files
docker compose exec crew uv run python -c "from crew.main import clear; clear()"
```

## 📂 Folder Structure

```
your-project/
├── crew/                  # 👈 Your CrewAI code goes here!
│   ├── src/              # Python source code
│   ├── pyproject.toml    # Dependencies  
│   ├── uv.lock          # Lock file (uv manages this)
│   └── .env             # Your API keys
├── output/               # 📄 Reports and outputs appear here
│   ├── crew-report_2025-05-24_20-23-40.md
│   └── crew-report_2025-05-24_20-24-37.md
├── scripts/              # 🚀 ECR deployment scripts
│   ├── deploy.sh         # Quick deployment
│   ├── release.sh        # Versioned releases
│   ├── build.sh          # Docker build
│   └── push-to-ecr.sh    # ECR push
└── docker-compose.yml    # 🐳 Docker magic
```

## 🎭 How to Use With Your Own Crew

1. Replace everything in `crew/` with your crew files
2. Make sure your main crew runner is at `crew.main:run` 
3. Add your API keys to `crew/.env`
4. Run `docker compose up -d --build` to start container
5. Run `docker compose exec crew uv run python -c "from crew.main import run; run()"` to execute
6. Watch the magic happen! ✨

### 🚀 For Production Deployment:
7. Set up AWS CLI with your profile
8. Run `./scripts/release.sh patch YOUR_ACCOUNT_ID` for versioned deployment
9. Use the ECR image URI in your CDK/ECS/Kubernetes deployments

## 🐛 Troubleshooting

**"Permission denied"** → Make sure Docker is running!

**"API key not found"** → Check your `crew/.env` file has real keys

**"Build failed"** → Make sure your `crew/` folder has the right files

**"Import error"** → Your crew main function should be at `crew.main:run`

**"Code changes not working"** → You need to rebuild: `docker compose down && docker compose up -d --build`

**"No AgentOps traces"** → Add `AGENTOPS_API_KEY` to `crew/.env` and rebuild

**"ECR deployment failed"** → Check the ECR troubleshooting section above

## 🌟 Pro Tips

- 🔄 **Code changes require rebuild**: Always run `docker compose down && docker compose up -d --build` after modifying code
- 📊 Outputs automatically save to `output/` folder with timestamps
- 🔍 Use `docker compose logs -f crew` to watch what's happening
- 🎮 Container stays running - you control when crew executes
- 📝 Each run creates a new file - compare results over time!
- 🗑️ Use the clear command to clean up old outputs
- 🔍 Enable AgentOps for amazing observability insights!
- 🧹 Run `docker system prune` occasionally to clean up
- 🚀 **Use `release.sh` for production**: Proper versioning and git tags
- ☁️ **ECR lifecycle policies**: Old images auto-cleanup (keeps 10 versions)
- 🔒 **Security first**: Images run as non-root user in production

---

**Happy AI building!** 🤖💪

## ☁️ Docker Deployment Options

Your CrewAI application builds into a **standard Docker image** that can be deployed anywhere! 🚀

### 🌍 Deploy Anywhere

This Docker image works with **any container platform**:
- 🐳 **Docker Hub** - `docker push your-username/concierge-crewai`
- ☁️ **AWS ECR** - Use our convenient scripts below
- 🔵 **Azure Container Registry** - `docker push yourregistry.azurecr.io/concierge-crewai`
- 🟢 **Google Container Registry** - `docker push gcr.io/your-project/concierge-crewai`
- 🟣 **GitHub Container Registry** - `docker push ghcr.io/your-username/concierge-crewai`
- 🏢 **Private registries** - Any Docker-compatible registry
- 🖥️ **Local deployment** - `docker run` directly

**The choice is yours!** We just provide ECR scripts for convenience. ✨

---

### 🛠️ AWS ECR Deployment (Convenience Scripts)

For AWS users, we've included ready-to-use scripts that handle ECR deployment automatically!

#### 🔧 Prerequisites

1. **AWS CLI installed**: [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **AWS Profile configured**: Make sure your `personal` profile is set up
   ```bash
   aws configure --profile personal
   # OR check existing: aws configure list --profile personal
   ```
3. **Docker running**: The scripts build and push Docker images

#### 🚀 ECR Deployment Options

**Option 1: Quick Deployment (Current Version)**
Deploy the current version without any version bumping:

```bash
# Deploy to default region (us-east-2)
./scripts/deploy.sh 633623909681

# Deploy to custom region
./scripts/deploy.sh 633623909681 us-west-2
```

**Option 2: Versioned Release (Recommended)**
Automatically bump version, commit, tag, and deploy:

```bash
# Patch release (0.1.0 → 0.1.1)
./scripts/release.sh patch 633623909681

# Minor release (0.1.0 → 0.2.0)  
./scripts/release.sh minor 633623909681

# Major release (0.1.0 → 1.0.0)
./scripts/release.sh major 633623909681

# Custom region
./scripts/release.sh patch 633623909681 us-west-2
```

#### 🎯 What Happens During ECR Deployment

**Quick Deploy (`deploy.sh`)**:
1. ✅ Builds Docker image with current version
2. ✅ Authenticates to AWS ECR  
3. ✅ Creates ECR repository (if needed)
4. ✅ Pushes images with multiple tags

**Versioned Release (`release.sh`)**:
1. ✅ Bumps version in `pyproject.toml`
2. ✅ Commits version change to git
3. ✅ Creates git tag (e.g., `v0.1.1`)
4. ✅ Builds Docker image with new version
5. ✅ Pushes to ECR with proper versioning

#### 🏷️ ECR Image Tags Created

Each ECR deployment creates multiple tags for flexibility:

```
633623909681.dkr.ecr.us-east-2.amazonaws.com/concierge-crewai:latest
633623909681.dkr.ecr.us-east-2.amazonaws.com/concierge-crewai:0.1.1
633623909681.dkr.ecr.us-east-2.amazonaws.com/concierge-crewai:0.1.1-a1b2c3d
```

- `latest` - Always points to most recent
- `0.1.1` - Specific version for production
- `0.1.1-a1b2c3d` - Version + git commit for debugging

#### 🔧 Using ECR Images in CDK/CloudFormation

After ECR deployment, reference your image in CDK:

```typescript
import { Repository, ContainerImage } from 'aws-cdk-lib/aws-ecr';

// Reference the repository
const repo = Repository.fromRepositoryName(this, 'CrewRepo', 'concierge-crewai');

// Use specific version (recommended for production)
const image = ContainerImage.fromEcrRepository(repo, '0.1.1');

// Or use latest (for development)
const latestImage = ContainerImage.fromEcrRepository(repo, 'latest');
```

#### 🛡️ ECR Security & Best Practices

- ✅ **Non-root user** - Images run as `appuser` for security
- ✅ **Image scanning** - Automatic vulnerability scanning enabled
- ✅ **Encryption** - Images encrypted at rest with AES256
- ✅ **Lifecycle policy** - Automatically cleans up old images (keeps 10 versions)
- ✅ **Multi-region support** - Deploy to any AWS region

#### 🔄 Git Workflow

After using `release.sh`, don't forget to push your changes:

```bash
# Push version changes and tags
git push origin main --tags
```

#### 🐛 Troubleshooting ECR Deployment

**"AWS CLI not found"** → Install AWS CLI

**"Invalid account ID"** → Check your AWS account ID: `aws sts get-caller-identity`

**"Access denied"** → Ensure your AWS profile has ECR permissions

**"Repository already exists"** → This is normal! The script will use the existing repo

**"Build failed"** → Make sure your `crew/` code builds locally first

**"Wrong AWS account"** → Set profile: `export AWS_PROFILE=personal`

---

### 🌟 Manual Docker Deployment

Prefer to handle deployment yourself? No problem!

```bash
# Build the image locally
./scripts/build.sh

# Tag for your preferred registry
docker tag concierge-crewai:latest your-registry.com/concierge-crewai:latest

# Push to any registry
docker push your-registry.com/concierge-crewai:latest

# Run anywhere
docker run --rm your-registry.com/concierge-crewai:latest
```
