
contract ConfigContract{
	//合约配置项数据结构
	struct ConfigItem{
		uint32 version;//该条合约的版本号
		uint time;//时间
		// 合约名 0用户合约 1恒生币合约 2交易流水合约 3商品合约 4 订单表合约
		// 消费合约从1000开始: [1000,2000]  1000 订单合约,1001 课程列表合约 
		uint32 contractId;//经过协商，改成uint32比较好，不用bytes1 
		address contractAddr;//合约地址 ,地址一定要在 bytes1前面 否则会出问题的
	}
	struct Proposal{
		//更换管理员的结构体
		address oldAdminAddr;
		address newAdminAddr;
		address sponsorAddr;//发起人的地址
	}
	Proposal public replaceAdminProposal;//保持更换管理员提议，只用一个
      // 3个管理员
	address public admin1;//管理员列表
	address public admin2;
	address public admin3;
	
	mapping(uint32=>ConfigItem[]) public maps;//保存历史变更合约情况，key 整个配置数（最多10），values  所有合约数组，一旦一个合约变更就保存老的
	uint32 public currentIndex=0;//当前的配置索引
	address oldContractAddr=0x0;//call回调时，必须得先找到 老的地址， 然后传进notify中，借以老合约更新新合约

	function ConfigContract(address admin1_,address admin2_,address admin3_){
		admin1=admin1_;
		admin2=admin2_;
		admin3=admin3_;
	}

   /**
   * 替换管理员，先不考虑投票机制那么麻烦的事情了，或者管理员密码丢了被人乱改那些
   * 注意：1）需要判断旧地址是否存在；2）新地址是否已经占用；3）另一位管理员复核即可
   * @param oldAddr_ 旧地址
   * @param newAddr_ 新地址
   */
  function replaceAdmin(address oldAddr_,address newAddr_) {
	  //该操作为管理员发起
	  if(!(isAdmin(msg.sender)&&isAdmin(oldAddr_)&&msg.sender!=newAddr_)){//发起人 不能 将一个管理员 替换为自己
			throw;
		}
	  if(!(replaceAdminProposal.oldAdminAddr==0x0&&replaceAdminProposal.newAdminAddr==0x0&&replaceAdminProposal.sponsorAddr==0x0)){	//必须此次投票结束后再投票，投票未结束
		  throw;
	  }
	  replaceAdminProposal.sponsorAddr=msg.sender;
	  replaceAdminProposal.oldAdminAddr=oldAddr_;
	  replaceAdminProposal.newAdminAddr=newAddr_;
  }
  	/*
	* 复核是否替换管理员
	* @param proposalIndex 提议的索引号，不是replaceAdminProposals数组索引，因为涉及到事务性
	* @param isSupport是否支持 
	*/
  function ConfirmReplaceAdmin(bool isSupport){
	  Proposal p=replaceAdminProposal;
	  //该操作为管理员发起
	  if(!(isAdmin(msg.sender)&&p.sponsorAddr!=msg.sender)){
			throw;
	  }
	  if(isSupport){
		  //支持换老管理员
		  if(p.oldAdminAddr==admin1){
			  admin1=p.newAdminAddr;
		  }else if(p.oldAdminAddr==admin2){
			  admin2=p.newAdminAddr;
		  }else if(p.oldAdminAddr==admin3){
			  admin3=p.newAdminAddr;
		  }
	  }
	  //提议 结构体清空
	  replaceAdminProposal.oldAdminAddr=0;
	  replaceAdminProposal.newAdminAddr=0;
	  replaceAdminProposal.sponsorAddr=0;
  }
  /**
  *是否是管理员
  *@param addr_ 
  *@return true：是管理员；false：不是管理员。
  */
  function isAdmin(address addr_) constant returns(bool){
    if(addr_!=admin1&&addr_!=admin2&&addr_!=admin3){
	    return false;
	}
	 return true;
  }
		
    function updateConfig(uint32[] contractIds_,address[] contractAddrs_){
	   //该操作为管理员发起
	   if(!isAdmin(msg.sender)){
			throw;
	   }
	    uint32 i;
		uint32 j;
		BaseContract baseContract;
		ConfigItem []newItems;
		if(maps[0].length==0){//第一次调用时 进入
		    newItems=maps[currentIndex];
			for(i=0;i<contractIds_.length;i++){
				baseContract=BaseContract(contractAddrs_[i]);
				uint32 version=baseContract.getVersion();//版本由 创建合约的人自己设定，并且取过来
				newItems.push(ConfigItem(version,now,contractIds_[i],contractAddrs_[i]));
			}
		}else{
			ConfigItem []oldItems=maps[currentIndex];
			currentIndex=(currentIndex+1)%10;	//采用10的循环数组，大于10之前的记录不保存，以避免map数组无限扩大
			newItems=maps[currentIndex];
			newItems.length=0;
			//要有两份拷贝的
			for(i=0;i<oldItems.length;i++){
				newItems.push(oldItems[i]);
			}
			bool isNewContract;
			//将要升级的合约 和 老的存在的合约去重保持最新的
			for(j=0;j<contractIds_.length;j++){
				for(i=0;i<newItems.length;i++){
					isNewContract=true;//所加的合约是否为新合约
					//判断 newItems[i].contractId_和contractId是否相同，solidity语法比较变态
					if(newItems[i].contractId==contractIds_[j]){
						isNewContract=false;
						//获取新合约的版本号
						baseContract=BaseContract(contractAddrs_[j]);
						newItems[i].version=baseContract.getVersion();
						newItems[i].contractAddr=contractAddrs_[j];
						newItems[i].time=now;
						break;
					}
				}
				if(isNewContract){//新加入的合约， 之前不存在的合约
					baseContract=BaseContract(contractAddrs_[j]);
					version=baseContract.getVersion();
					newItems.push(ConfigItem(version,now,contractIds_[j],contractAddrs_[j]));
				}
			}
		
		}
		//通知合约配置已发生变更
		for(i=0;i<newItems.length;i++){
			newItems[i].contractAddr.call(bytes4(sha3("notifyChanged()")));
		}
	}

	/**
	* 当前合约情况的总数
	*/
	function getCurrentContractsCount() constant returns(uint32 ){
		return (uint32)(maps[currentIndex].length);
	}
	/*
GoodsContract	* 当前合约的详情
	*/
	function getCurrentContractDetail(uint32 index_)constant returns(uint32,uint,uint32,address){
		ConfigItem item=maps[currentIndex][index_];
		return (item.version,item.time,item.contractId,item.contractAddr);
	}
	/**
	* 根据 合约id 获取 合约版本,创建时间,地址
	* @param contractId_ 合约Id
	*/
	function getCurrentContractAddress(uint32 contractId_) constant returns(uint32,uint,address){
		ConfigItem[] items=maps[currentIndex];
		for(uint32 i=0;i<items.length;i++){
			if(items[i].contractId==contractId_){
				return (items[i].version,items[i].time,items[i].contractAddr);
			}
		}
		return (0,0,0x0);//无效情况
	}
}

