**Aws Architecture:**
      VPC
      ├── Public Subnet
      │   ├── Internet Gateway
      │   ├── NAT Gateway
      │   └── 1 Public EC2
      │
      └── Private Subnet
          ├── Route via NAT
          ├── Private EC2-1
          └── Private EC2-2

**Distributed deployment on cloud VMs**
Architecture :
Internet
   |
   v
[ API Gateway VM ]  <-- Public IP only here
   |
   | Private subnet RPC
   v
[ Caller Worker VM ]
   |
   | RPC
   v
[ Inference Worker VM ]


**Steps to Redo From sratch**

Open terminal : git clone >

aws configure -> fill access key and region 

Make sure region is same in varible file and provide file with configure region

Terrafrom apply wait 5 to 7 mins to complete up infra.

Then follow each setp by given below, first connectin public vm reapt step accordingly. Installtion order Api -> caller -> interface

Debugging command for iii:
  iii worker start <name>     # start one worker
  iii worker stop <name>      # stop one worker
  iii worker restart <name>   # stop then start

  iii worker status <name>             # config, sandbox state, recent logs
  iii worker logs <name>               # stream the worker's logs
  iii worker exec <name> -- <command>  # run a command inside the worker



**SSH Into Public vm:
**
   1.iii --config config.yaml
   2. Keep this terminal and open new terminal
   3.iii worker add iii-http

**Caller-Worker**

ssh in caller vm &:

export III_URL=ws://<API-PRIVATE-IP>:49134

iii worker add ./workers/caller-worker

**Interface order:**

**ssh into interaface vm &:**

python3 -m venv venv
source venv/bin/activate

pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

pip install --no-cache-dir transformers

pip install -r requriement.txt

export III_URL=ws://API-IP:49134

iii worker add ./workers/inference-worker 


**Architecture becomes:**
                Internet
                    |
              [ API VM ]
             iii-http worker
                    |
          iii engine websocket
                    |
         ---------------------
         |                   |
 [ Caller Worker VM ]   [ Inference Worker VM ]
    TypeScript               Python

**Test Url**
curl -X POST http://PUBLIC-IP:3111/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "messages": [
    {
      "role": "user",
      "content": "Hello"
    }
  ]
}'

**Output:**
{
  "response": "Hello! How can I help you today?"
}





























 
