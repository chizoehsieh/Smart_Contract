// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 < 0.9.0;

contract loan {
    address public bank;
    string public bankName;
    uint private studentNum;

    struct studentLoan{
        address studentAddress;
        string studentID;
        uint tuiion;
        uint handlingFee;
        uint startTime;
        uint interest;     //此筆貸款是否收取利息，0為不收，數字為利息比率 (因會照學生家庭收入收取不同利息)
        uint done;         //是否還完此筆貸款，0未繳清，1繳清
    }

    struct student{
        address studentAddress;
        address schoolAddress;
        string studentID;
        string schoolName;
        string studentName;
        uint allLoanMoney;
        uint loanNum;
        // mapping(uint => studentLoan) allLoanDetails;
        // studentLoan[] allLoanDetails;
    }

    student[] students;
    studentLoan[][] allLoanDetails;

    constructor (string memory _bankName)  {   //建構子
        bank = msg.sender;
        bankName = _bankName;
        studentNum = 0;
    }

    modifier onlyBank{
        require(msg.sender == bank);
        _;
    }

    modifier onlyStudent{
        bool qual = false;
        for (uint i=0; i<studentNum; i++){
            if(students[i].studentAddress == msg.sender){
                qual = true;
            }
        }
        
        require(qual == true);
        _;
    }

    function register(address _studentAddress, address _schoolAddress, string memory _studentID, string memory _schoolName, string memory _studentName, uint _amount) public onlyBank{  //註冊學生資料
        students[studentNum] = student({
            studentAddress : _studentAddress,
            schoolAddress : _schoolAddress,
            studentID : _studentID,
            schoolName : _schoolName,
            studentName : _studentName,
            allLoanMoney : _amount,
            loanNum : 0


        });
        
        // students.push(student({
        //     studentAddress : _studentAddress,
        //     schoolAddress : _schoolAddress,
        //     studentID : _studentID,
        //     schoolName : _schoolName,
        //     studentName : _studentName,
        //     allLoanMoney : _amount,
        //     loanNum : 0
        // }));
        studentNum ++;
    }


    function newLoan(address _studentAddress, string memory _studentID, uint _tuition, uint _handlingFee, uint _startTime, uint _interest) public onlyBank{  //新增貸款資料
        for (uint i=0; i < studentNum ; i++){
            if (students[i].studentAddress == _studentAddress){
                allLoanDetails[i].push(studentLoan({
                    studentAddress : _studentAddress,
                    studentID : _studentID,
                    tuiion : _tuition,
                    handlingFee : _handlingFee,
                    startTime : _startTime,
                    interest : _interest,
                    done : 0
                }));
                students[i].allLoanMoney += _tuition + _handlingFee;
                payable(students[i].schoolAddress).transfer(_tuition);
                break;
            }
            
        }
    }

    function repayment(string memory _studentID) public payable onlyStudent returns(string memory name, uint amount){  //還款
        for (uint i=0; i < studentNum ; i++){
            if (students[i].studentAddress == msg.sender && keccak256(abi.encodePacked(students[i].studentID)) == keccak256(abi.encodePacked(_studentID))){
                if (msg.value <= students[i].allLoanMoney){
                    students[i].allLoanMoney -= msg.value;
                    
                }
                else if (students[i].allLoanMoney < msg.value) {
                    uint money = msg.value;
                    money -= students[i].allLoanMoney;
                    students[i].allLoanMoney = 0;
                    payable(msg.sender).transfer(money);

                }
                return(students[i].studentName, students[i].allLoanMoney);

            }
            
        }
    }

    function change_address(address _changeAddress) public onlyStudent{  //更改學生錢包位址
        for(uint i=1; i<=studentNum; i++){
            if(students[i].studentAddress == msg.sender){
                students[i].studentAddress = _changeAddress;
            }
        }
    }

    function remainingAmount() public onlyStudent view returns(address, string memory, uint){  //查詢剩餘未繳清金額
        for(uint i=1; i<=studentNum; i++){
            if(students[i].studentAddress == msg.sender){
                return(students[i].studentAddress, students[i].studentName, students[i].allLoanMoney);
            }
        }
        return(msg.sender,"Can't Search",0);
    }
}