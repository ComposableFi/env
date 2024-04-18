# really must decrypt using tools outthere
if [ -f /root/.env ]; then
  source /root/.env
else
  echo "No .env file found"
fi