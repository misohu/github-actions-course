const core = require('@actions/core');
const github = require('@actions/github');
const fs = require('fs');

try {
  const name = core.getInput('name');  // name is from action.yaml (the input)
  console.log(`Arg received ${name}`);
  
  console.log('Workdir:');
  fs.readdirSync('.').forEach(file => {
    console.log(file);
  });

  const payload = JSON.stringify(github.context.payload, undefined, 2); // This is how we can get the github context in the action
  console.log(`The event payload: ${payload}`);
  
  fs.writeFileSync('name.txt', name);
  core.setOutput('processed-name', name);
} catch (error) {
  core.setFailed(error.message);
}
