
<template>
    <div>
        <h1>Hello</h1>
        <div class="links">
            <button @click="sign">Sign</button>
        </div>
        <p>{{ sig }}</p>
    </div>
</template>

<script>
    import Web3 from "web3";
    export default {
        data() {
            return {
                browserWeb3: null,
                sig: "aaaa",
                contract: "0xba8dc1a692093d8abd34e12aa05a4fe691121bb6",
                relayer: "0xca35b7d915458ef540ade6068dfe2f44e8fa733c",
            }
        },

        mounted() {
            this.browserWeb3 = new Web3(web3.currentProvider);
        },

        methods: {
            async sign() {
                let web3 = this.browserWeb3;
                let accounts = await web3.eth.getAccounts();
                let from = accounts[0];
                let data = web3.utils.soliditySha3(
                    {t: 'address', v: this.contract },
                    {t: 'address', v: from },
                    {t: 'uint256', v: 100 },
                    {t: 'uint8', v: 1 },
                    {t: 'uint256', v: 1 },
                    {t: 'address', v: this.relayer },
                );
                this.sig = await web3.eth.personal.sign(data, from, "");
            },

            async erc712sign() {
                console.log(this.browserWeb3);
                let typedData = this.getTypedData();
                let accounts = await this.browserWeb3.eth.getAccounts();
                this.sig = await this.browserWeb3.givenProvider.sendAsync({
                    method: 'eth_signTypedData_v3',
                    params: [accounts[0], typedData],
                    from: accounts[0],
                });
            },

            getTypedData() {
                return JSON.stringify({
                    "types": {
                        "EIP712Domain": [
                            {"name":"name","type":"string"},
                            {"name":"version","type":"string"},
                            {"name":"chainId","type":"uint256"},
                            {"name":"verifyingContract","type":"address"}
                        ],
                        // "Person":[
                        //     {"name":"name","type":"string"},
                        //     {"name":"wallet","type":"address"}
                        // ],
                        "Mail":[
                            {"name":"from","type":"string"},
                            {"name":"to","type":"string"},
                            {"name":"contents","type":"string"}
                        ]
                    },
                    "primaryType": "Mail",
                    "domain":{
                        "name":"Ether Mail",
                        "version":"1",
                        "chainId":1,
                        "verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
                    },
                    "message":{
                        "from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},
                        "to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},
                        "contents":"Hello, Bob!"
                    }
                });
            }
        }

    }

</script>