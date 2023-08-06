//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Certification
{
    uint256 public no_of_certi=0;
    uint256 public no_of_org=0;
    uint256 public no_of_candi=0;

    struct Candidate
    {
        string name;
        uint256 id;    // 
        uint256 role;
        string pass;
    }
    struct Org
    {
         string name;
         uint256 id;
         uint256 role;   // 1 institute
         string pass;
    }
    struct Certificate
    {
        Candidate candate;
        string course_name;
        string org_name;
        uint256 date;
        uint256 certi_no;
        
    } 


      function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
    bytes memory b1 = bytes(s1);
    bytes memory b2 = bytes(s2);
    uint256 l1 = b1.length;
    if (l1 != b2.length) return false;
    for (uint256 i=0; i<l1; i++) {
        if (b1[i] != b2[i]) return false;
    }
    return true;
    }

  
  mapping(uint256 => Certificate) public certificates;
  Certificate[] all_certi;
  Org[] public all_institute;
  Candidate[] public all_candi;


mapping(uint256=>address) public id_to_address;
mapping(uint256 =>address) public owner_of_certi;
mapping(uint256=>uint256[]) public cert_access_org;




    function create_certificate(string memory _owner_name ,uint256 _id,string memory _org_name,string memory _course_name,uint256 _date,uint256 role) public returns(uint256)
    {
        require(role==1,"Only Institutes can assign certificate");
         Certificate storage certi = certificates[no_of_certi];

        certi.candate.name=_owner_name;
        certi.candate.id=_id;
        certi.org_name=_org_name;
        certi.date=_date;
        certi.course_name=_course_name;

       


        no_of_certi++;  
        certi.certi_no=no_of_certi; 

        all_certi.push(certi);
        owner_of_certi[no_of_certi]=id_to_address[_id];
        
      


        return no_of_certi;
    }

    function view_certi(uint256 certi_no) public view returns(Certificate memory)
    {
       // require(certi_no>no_of_certi,"Certificate with given id does not exist!!");
        return (certificates[certi_no-1]);
    }
    function register_org(string memory _name,string memory _pass) public returns (bool)
    {
        bool success=true;
        for(uint256 i=0;i<all_institute.length;i++)
        {
           Org memory curr_org= all_institute[i];
            if(stringsEquals(curr_org.name,_name))
            {
               success=false;
               break;
            }

        }
        if(success)
        {
            
            no_of_org+=1;
             Org memory new_org = Org(_name,no_of_org,1,_pass);
            all_institute.push(new_org);
        }

        

        return success;
    }

    function get_inst_id(string memory name) public view returns(uint256)
    {
        uint256 id=0;
        for(uint256 i=0;i<all_institute.length;i++)
        {
           Org memory curr_org= all_institute[i];
            if(stringsEquals(curr_org.name,name))
            {
               id=curr_org.id;
               break;
            }

        }
        return id;
    }
    

    function login_org(string memory _name,string memory _pass) public view returns (bool)
    {
        bool success=false;
        for(uint256 i=0;i<all_institute.length;i++)
        {
           Org memory curr_org= all_institute[i];
            if(stringsEquals(curr_org.name,_name))
            {
               if(stringsEquals(curr_org.pass,_pass))
               {
                 success=true;
               }
            }

        }
        return success;
    }
  
     function register_candi(string memory _name,string memory _pass) public returns (bool)
    {
        bool success=true;
        for(uint256 i=0;i<all_candi.length;i++)
        {
        Candidate memory curr_candi= all_candi[i];
            if(stringsEquals(curr_candi.name,_name))
            {
               success=false;
               break;
            }

        }
        if(success)
        {
            
            Candidate memory new_candi = Candidate(_name,no_of_candi+1,0,_pass);
            id_to_address[no_of_candi+1]=msg.sender;
            all_candi.push(new_candi);
            no_of_candi++;
        }

        

        return success;
    }
    

    function login_candi(uint256 _id,string memory _pass) public view returns (bool)
    {
        bool success=false;
        for(uint256 i=0;i<all_candi.length;i++)
        {
           Candidate memory curr_org= all_candi[i];
            if(curr_org.id==_id)
            {
               if(stringsEquals(curr_org.pass,_pass))
               {
                 success=true;
               }
            }

        }
        return success;
    }

  

     function getCertificate(uint256 _id) public view returns (Certificate[] memory) {
        Certificate[] memory mycerti = new Certificate[](no_of_certi);

        for(uint i = 0; i < no_of_certi; i++) {
            Certificate memory certi = all_certi[i];
            uint j = 0;
            if(certi.candate.id==_id)
            {
                mycerti[j] = certi;
                j = j + 1;
            }
        }

        return mycerti;
    }

  

   function give_access(string memory name,uint256 id) public  
 {
       uint256 inst_id=get_inst_id(name);
       cert_access_org[id].push(inst_id);

 }

 function access_list(uint256 id) public view returns(uint256 [] memory)
 {
      uint256[] memory access=cert_access_org[id];
      return access;
 }

   function remove_element_in_array(uint256[] storage Array, uint256 id) internal 
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++)
        {
            if(Array[i] == id)
            {
                check = true;
                del_index = i;
            }
        }
       
            if(Array.length == 1)
            {
                delete Array[del_index];
            }
            else 
            {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];

            }

            Array.pop();
            
            
        
    }

 function revoke_access(uint256 certi_id,uint256 id) public
  {

    uint256[] storage arr=cert_access_org[certi_id];
    remove_element_in_array(arr,id);
  }

   
    

}