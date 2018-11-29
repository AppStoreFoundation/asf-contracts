## Vulnerability Disclosure policy

### Program Rules

We belive that working with skilled security researchers is fundamental to identify weaknessess in any technology. If you belive to have found a vulnerability in one of our products please reach out and we ensure you will be rewarded for you discovery.

### Scope

### Vulnerability Evaluation

Once a vulnerability is reported, AppCoins team will rate the security issue considering the [OWASP model](https://www.owasp.org/index.php/OWASP_Risk_Rating_Methodology). A vulnerability will be classified as the product of impact of the exploit and likelihood of it being used.

**Impact x Likelihood = Risk Severity**


<table>
<tbody><tr>
<th colspan="5" align="center">Overall Risk Severity</th>
</tr>
<tr>
<th rowspan="4" width="15%" align="center">Impact</th>
<td width="15%" align="center">HIGH</td>
<td width="15%" bgcolor="orange" align="center">Medium</td>
<td width="15%" bgcolor="red" align="center">High</td>
<td width="15%" bgcolor="pink" align="center">Critical</td>
</tr>
<tr>
<td align="center">MEDIUM</td>
<td bgcolor="yellow" align="center">Low</td>
<td bgcolor="orange" align="center">Medium</td>
<td bgcolor="red" align="center">High</td>
</tr>
<tr>
<td align="center">LOW</td>
<td bgcolor="lightgreen" align="center">Note</td>
<td bgcolor="yellow" align="center">Low</td>
<td bgcolor="orange" align="center">Medium</td>
</tr>
<tr>
<td align="center">&nbsp;</td>
<td align="center">LOW</td>
<td align="center">MEDIUM</td>
<td align="center">HIGH</td>
</tr>
<tr>
<td align="center">&nbsp;</td>
<th colspan="4" align="center">Likelihood</th>
</tr>
</tbody>
</table>

### Rewards

Our minimum reward is **30 Euros**

Considering the risk assigned by the AppCoins team, the possible rewards are defined as following:
<table>
<thead><tr><th>Qualification</th>
<th>Score CVSS</th>
<th>Bounty</th>
</tr></thead><tbody><tr><td>None</td>
<td>N/A</td>
<td>No Bounty</td>
</tr><tr><td style="font: lightgreen"><span ><strong>Low</strong></span></td>
<td>0.1 - 3.9</td>
<td>&lt;= 50€</td>
</tr><tr><td><span style="color:#FFA500;"><strong>Medium</strong></span></td>
<td>4.0 - 6.9</td>
<td>&lt;= 100€</td>
</tr><tr><td><span style="color:#FF0000;"><strong>High</strong></span></td>
<td>7.0 - 8.9</td>
<td>&lt;= 300€</td>
</tr><tr><td><strong>Critical</strong></td>
<td>9.0 - 10.0</td>
<td>&lt;= 500 €</td>
</tr></tbody>
</table>


### Eligibility and Responsible Disclosure

We thank everyone submitting valid reports. In order for a report to be eligible for a monetary rewards, the following conditions need to be respected:
 - You must be the first reporter of a vulnerabiliby
 - Any vulnerability found must be reported no later than 24 hours after discovery throught **email or bug bounty platform**.
 - You must send clear description of the report along with steps to reproduce the issue, proof of concept code may be required.
 - You must refrain from exploiting a vulnerability which may lead to service interruption on Ethereum main network, **please use ropsten network for testing**.
 - You must not leak, manipulate or destroy user data on Ethereum main network contracts.
 - You must not try to exploit the bug and access contract data for further vulnerabilities.
 - You must not disclose any of the vulnerability information publicly before our team evaluates the vulnerability and acts acordingly.

Reports are reviewed within **5 working days** (we'll try to respond sooner is possible).
We will prioritize vulnerability fixes based on the risk severity, thus **it is mandatory to contact us before any public vulnerability disclosure**. 


### Scope
This bug bounty is valid for every smart contract maintained by AppCoins Protocol Team.
The only smart contracts out of the scope of this bugbounty is the AppCoins token contract (ERC-20 token contract).
- Denial of service attacks against Ethereum network are strictly out of scope of this program
- AppCoins token contract (ERC-20 token contract) is out of scope of this program

####Qualifying Vulnerabilities
 - Any vulnerability related to AppCoins Credits Balance smart contract (https://github.com/AppStoreFoundation/asf-contracts/blob/dev/contracts/AppCoinsCreditsBalance.sol)

####NON-Qualifying Vulnerabilities
 - Any vulnerability against AppStore Foundation servers
 - Any hypothetical flaw or best practices without exploitable POC
 - Any physical attempts against AppStore Foundation (ASF) or Aptoide offices or data centers
 - Vulnerabilities found on front-end services, AppStore Foundation and AppCoins websites
 - Vulnerabilities found on ASF wallet or ASF SDK
 - Vulnerabilities found on ASF Unity plugin
 - Vulnerabilities related to Solidity compiler or language design


Authorized Conduct

Any activities conducted in a manner consistent with this policy will be considered authorized conduct and we will not initiate legal action against you. If legal action is initiated by a third party against you in connection with activities conducted under this policy, we will take steps to make it known that your actions were conducted in compliance with this policy.

Thank you for helping keep App Store Foundation and our users safe!
