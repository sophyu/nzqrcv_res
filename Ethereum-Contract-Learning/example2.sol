
contract ConfigContract{
	//��Լ���������ݽṹ
	struct ConfigItem{
		uint32 version;//������Լ�İ汾��
		uint time;//ʱ��
		// ��Լ�� 0�û���Լ 1�����Һ�Լ 2������ˮ��Լ 3��Ʒ��Լ 4 �������Լ
		// ���Ѻ�Լ��1000��ʼ: [1000,2000]  1000 ������Լ,1001 �γ��б��Լ 
		uint32 contractId;//����Э�̣��ĳ�uint32�ȽϺã�����bytes1 
		address contractAddr;//��Լ��ַ ,��ַһ��Ҫ�� bytes1ǰ�� �����������
	}
	struct Proposal{
		//��������Ա�Ľṹ��
		address oldAdminAddr;
		address newAdminAddr;
		address sponsorAddr;//�����˵ĵ�ַ
	}
	Proposal public replaceAdminProposal;//���ָ�������Ա���飬ֻ��һ��
      // 3������Ա
	address public admin1;//����Ա�б�
	address public admin2;
	address public admin3;
	
	mapping(uint32=>ConfigItem[]) public maps;//������ʷ�����Լ�����key ���������������10����values  ���к�Լ���飬һ��һ����Լ����ͱ����ϵ�
	uint32 public currentIndex=0;//��ǰ����������
	address oldContractAddr=0x0;//call�ص�ʱ����������ҵ� �ϵĵ�ַ�� Ȼ�󴫽�notify�У������Ϻ�Լ�����º�Լ

	function ConfigContract(address admin1_,address admin2_,address admin3_){
		admin1=admin1_;
		admin2=admin2_;
		admin3=admin3_;
	}

   /**
   * �滻����Ա���Ȳ�����ͶƱ������ô�鷳�������ˣ����߹���Ա���붪�˱����Ҹ���Щ
   * ע�⣺1����Ҫ�жϾɵ�ַ�Ƿ���ڣ�2���µ�ַ�Ƿ��Ѿ�ռ�ã�3����һλ����Ա���˼���
   * @param oldAddr_ �ɵ�ַ
   * @param newAddr_ �µ�ַ
   */
  function replaceAdmin(address oldAddr_,address newAddr_) {
	  //�ò���Ϊ����Ա����
	  if(!(isAdmin(msg.sender)&&isAdmin(oldAddr_)&&msg.sender!=newAddr_)){//������ ���� ��һ������Ա �滻Ϊ�Լ�
			throw;
		}
	  if(!(replaceAdminProposal.oldAdminAddr==0x0&&replaceAdminProposal.newAdminAddr==0x0&&replaceAdminProposal.sponsorAddr==0x0)){	//����˴�ͶƱ��������ͶƱ��ͶƱδ����
		  throw;
	  }
	  replaceAdminProposal.sponsorAddr=msg.sender;
	  replaceAdminProposal.oldAdminAddr=oldAddr_;
	  replaceAdminProposal.newAdminAddr=newAddr_;
  }
  	/*
	* �����Ƿ��滻����Ա
	* @param proposalIndex ����������ţ�����replaceAdminProposals������������Ϊ�漰��������
	* @param isSupport�Ƿ�֧�� 
	*/
  function ConfirmReplaceAdmin(bool isSupport){
	  Proposal p=replaceAdminProposal;
	  //�ò���Ϊ����Ա����
	  if(!(isAdmin(msg.sender)&&p.sponsorAddr!=msg.sender)){
			throw;
	  }
	  if(isSupport){
		  //֧�ֻ��Ϲ���Ա
		  if(p.oldAdminAddr==admin1){
			  admin1=p.newAdminAddr;
		  }else if(p.oldAdminAddr==admin2){
			  admin2=p.newAdminAddr;
		  }else if(p.oldAdminAddr==admin3){
			  admin3=p.newAdminAddr;
		  }
	  }
	  //���� �ṹ�����
	  replaceAdminProposal.oldAdminAddr=0;
	  replaceAdminProposal.newAdminAddr=0;
	  replaceAdminProposal.sponsorAddr=0;
  }
  /**
  *�Ƿ��ǹ���Ա
  *@param addr_ 
  *@return true���ǹ���Ա��false�����ǹ���Ա��
  */
  function isAdmin(address addr_) constant returns(bool){
    if(addr_!=admin1&&addr_!=admin2&&addr_!=admin3){
	    return false;
	}
	 return true;
  }
		
    function updateConfig(uint32[] contractIds_,address[] contractAddrs_){
	   //�ò���Ϊ����Ա����
	   if(!isAdmin(msg.sender)){
			throw;
	   }
	    uint32 i;
		uint32 j;
		BaseContract baseContract;
		ConfigItem []newItems;
		if(maps[0].length==0){//��һ�ε���ʱ ����
		    newItems=maps[currentIndex];
			for(i=0;i<contractIds_.length;i++){
				baseContract=BaseContract(contractAddrs_[i]);
				uint32 version=baseContract.getVersion();//�汾�� ������Լ�����Լ��趨������ȡ����
				newItems.push(ConfigItem(version,now,contractIds_[i],contractAddrs_[i]));
			}
		}else{
			ConfigItem []oldItems=maps[currentIndex];
			currentIndex=(currentIndex+1)%10;	//����10��ѭ�����飬����10֮ǰ�ļ�¼�����棬�Ա���map������������
			newItems=maps[currentIndex];
			newItems.length=0;
			//Ҫ�����ݿ�����
			for(i=0;i<oldItems.length;i++){
				newItems.push(oldItems[i]);
			}
			bool isNewContract;
			//��Ҫ�����ĺ�Լ �� �ϵĴ��ڵĺ�Լȥ�ر������µ�
			for(j=0;j<contractIds_.length;j++){
				for(i=0;i<newItems.length;i++){
					isNewContract=true;//���ӵĺ�Լ�Ƿ�Ϊ�º�Լ
					//�ж� newItems[i].contractId_��contractId�Ƿ���ͬ��solidity�﷨�Ƚϱ�̬
					if(newItems[i].contractId==contractIds_[j]){
						isNewContract=false;
						//��ȡ�º�Լ�İ汾��
						baseContract=BaseContract(contractAddrs_[j]);
						newItems[i].version=baseContract.getVersion();
						newItems[i].contractAddr=contractAddrs_[j];
						newItems[i].time=now;
						break;
					}
				}
				if(isNewContract){//�¼���ĺ�Լ�� ֮ǰ�����ڵĺ�Լ
					baseContract=BaseContract(contractAddrs_[j]);
					version=baseContract.getVersion();
					newItems.push(ConfigItem(version,now,contractIds_[j],contractAddrs_[j]));
				}
			}
		
		}
		//֪ͨ��Լ�����ѷ������
		for(i=0;i<newItems.length;i++){
			newItems[i].contractAddr.call(bytes4(sha3("notifyChanged()")));
		}
	}

	/**
	* ��ǰ��Լ���������
	*/
	function getCurrentContractsCount() constant returns(uint32 ){
		return (uint32)(maps[currentIndex].length);
	}
	/*
GoodsContract	* ��ǰ��Լ������
	*/
	function getCurrentContractDetail(uint32 index_)constant returns(uint32,uint,uint32,address){
		ConfigItem item=maps[currentIndex][index_];
		return (item.version,item.time,item.contractId,item.contractAddr);
	}
	/**
	* ���� ��Լid ��ȡ ��Լ�汾,����ʱ��,��ַ
	* @param contractId_ ��ԼId
	*/
	function getCurrentContractAddress(uint32 contractId_) constant returns(uint32,uint,address){
		ConfigItem[] items=maps[currentIndex];
		for(uint32 i=0;i<items.length;i++){
			if(items[i].contractId==contractId_){
				return (items[i].version,items[i].time,items[i].contractAddr);
			}
		}
		return (0,0,0x0);//��Ч���
	}
}

