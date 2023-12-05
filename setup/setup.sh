
if [[ "$(uname)" == "Darwin" ]]; then
    echo "This is macOS."
else
    echo "This is not macOS."
    exit 1
fi

if command -v brew &> /dev/null
then
    echo "Homebrew is installed."
else
    echo "Homebrew is not installed. please install brew package manager from https://brew.sh/"
    exit 1
fi

echo "update brew package manager to its latest version"
brew update

echo "install brew package manager to its latest version"
brew install colima kubectl helm argo just


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add argo-workflows https://argoproj.github.io/argo-helm/