set -e

# Delete services first
echo "Deleting services..."
cf delete-service -f "swift-enterprise-demo-alert"
echo "Services deleted."

# Create services
echo "Creating services..."
cf create-service alertnotification authorizedusers "swift-enterprise-demo-alert"
echo "Services created."
