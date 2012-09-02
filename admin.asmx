<%@ WebService Language="C#"  Class="Admin" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.Xml.Linq;
using System.IO;
using System.Data;
using PENAVICO;

/// <summary>
///Admin 客户信息操作
/// </summary>
[WebService(Namespace = "http://www.wztnet.com")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class Admin : System.Web.Services.WebService{
    public Admin(){
	}    


	public String GetAdminInfo(){
			String password = "";
			ATLDATALib.IDBDataAtl rs = Tpp.RPC.EmployeeControl.Employee.Load("emp_id" , HttpContext.Current.Session["Member_Id"]);
			if (rs.IsOK()){
				password = rs.GetStringTName("password");
			}

			//获取顶部菜单信息
			//String topmenu = GetPriXml2Json("topmenu" , "menu");
			//获取快捷菜单
			//String logomenu = GetPriXml2Json("logomenu" , "menu");
			//获取计划树菜单
			//String plantree = GetPriXml2Json("plantree" , "tree");

			String hash = HttpContext.Current.Session["Member_Id"].ToString() +"-"+ HttpContext.Current.Session["Member_Code"].ToString();
			hash = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(hash, "MD5"); //MD5
			var str = "<data";
			str += " id = \""+HttpContext.Current.Session["Member_Id"].ToString()+"\" ";
			str += " name = \""+HttpContext.Current.Session["Member_Name"].ToString()+"\" ";
			str += " code = \""+HttpContext.Current.Session["Member_Code"].ToString()+"\" ";
			str += " loc = \""+HttpContext.Current.Session["Member_Loc"].ToString()+"\" ";
			str += " hash = \""+hash+"\" ";
			//str += " duty = \""+HttpContext.Current.Session["Member_Duty"].ToString()+"\" ";
			//str += " topmenu = \""+topmenu+"\" ";
			str +=">";
			//str +="<privilege>"+HttpContext.Current.Session["Member_PriList"].ToString()+"</privilege>";
			//str +="<topmenu>"+topmenu+"</topmenu>";
			//str +="<logomenu>"+logomenu+"</logomenu>";
			//str +="<plantree>"+plantree+"</plantree>";
			str +="</data>";
			
			String hashfile = HttpContext.Current.Server.MapPath("docs/loginhash.xml");
			XmlDataDocument bd = new XmlDataDocument();		
			bd.Load(hashfile);

			//查找是否有该用户
			XmlElement node = (XmlElement)bd.SelectSingleNode("//login[@hash='"+hash+"']");
			if (node == null){
				//如果没有 , 写入一行
				XmlElement logins = (XmlElement)bd.SelectSingleNode("//logins");
                XmlElement login = bd.CreateElement("login");
                logins.AppendChild(login);
				login.SetAttribute("id" , HttpContext.Current.Session["Member_Id"].ToString());
				login.SetAttribute("name" , HttpContext.Current.Session["Member_Name"].ToString());
				login.SetAttribute("code" , HttpContext.Current.Session["Member_Code"].ToString());
				login.SetAttribute("password" , password);
				login.SetAttribute("hash" , hash);
				bd.Save(hashfile);
			}

			return str;
	}

	private String GetPriXml2Json(String filename , String type){
		String result = "";
		String plstr = HttpContext.Current.Session["Member_PriList"].ToString();

		XDocument xd = XDocument.Load(HttpContext.Current.Server.MapPath("config/"+filename+".xml"));

		if (HttpContext.Current.Session["Member_Code"].ToString() != "admin") {
			var q = from o in xd.Descendants("node") where
						o.Attribute("permission") !=null && !plstr.Contains(o.Attribute("permission").Value) && o.Attribute("permission").Value != "uncheck"
					select o;
			q.Remove();
		}
		var xml = xd.ToString();
		//HttpContext.Current.Response.Write(xml);
		//HttpContext.Current.Response.End();
		XmlDataDocument d = new XmlDataDocument();
		d.LoadXml(xml);

		var root = d.SelectSingleNode("root");
		if (root == null) return result;
		if (type == "tree"){
			result = "[" + Common.Xml2TreeJson(root) + "]";
		}else{
			result = "[" + Common.Xml2MenuJson(root) + "]";
		}
		return result;	
	}


    [WebMethod(EnableSession = true, Description = "获取客户列表")]
    public XmlDataDocument CheckSession(){
        XmlDataDocument bd = new XmlDataDocument();
        Tpp Tpp = new Tpp();
        Tpp.Security.ChkStatus_flag = true;
        bool rs = Tpp.Member.Status;
		if (rs){

			var info = GetAdminInfo();

            return Page.GetResponseXml("succ", "登录成功" , info);
			//return Page.GetResponseXml("succ" , HttpContext.Current.Session["Member_Name"].ToString());
		}else{
			return Page.GetResponseXml("unsucc" , "失效!");
		}
	}


//检测登录
    [WebMethod(EnableSession = true, Description = "获取客户列表")]
    public XmlDataDocument CheckLogin(String u_name , String u_pass ){
        XmlDataDocument bd = new XmlDataDocument();
		ATLDATALib.IDBDataAtl list;

        if ((Tpp.IsEmpty(u_name)) || (Tpp.IsEmpty(u_pass))) {
			return Page.GetResponseXml("unsucc", "请填写用户名和密码!");
		}
        Login login = new Login();
        login.Name = u_name;
        login.Password = u_pass;
        var cg = login.CheckLogin();

        if (cg){

			var info = GetAdminInfo();
			//HttpContext.Current.Response.Write(info);
			//HttpContext.Current.Response.End();
            bd = Page.GetResponseXml("succ", "登录成功" , info);
        }else{
            bd = Page.GetResponseXml("unsucc", (Tpp.IsEmpty(login.Errinfo) ? "服务出现意外错误!!" : login.Errinfo));
        }
        return bd;
    } 

//退出登录
    [WebMethod(EnableSession = true, Description = "退出登录")]
    public XmlDataDocument Logout()
    {
        XmlDataDocument bd = new XmlDataDocument();
		HttpContext.Current.Session["session"] = "";
		HttpContext.Current.Session["Member_Id"] = "";
		HttpContext.Current.Session["Member_Code"] = "";
		HttpContext.Current.Session["Member_Name"] = "";
		HttpContext.Current.Session["Member_Loc"] = "";
		HttpContext.Current.Session["Member_Duty"] ="";

		bd = Page.GetResponseXml("succ", "退出成功");
		return bd;
    }	
//修改密码
    [WebMethod(EnableSession = true, Description = "退出登录")]
    public XmlDataDocument UpdatePassword(string opass , string npass , string vpass){
        XmlDataDocument bd = new XmlDataDocument();
		ATLDATALib.IDBDataAtl rs;
		string emp_id = HttpContext.Current.Session["Member_Id"].ToString();

		rs = Tpp.RPC.EmployeeControl.Employee.Load("emp_id" , emp_id);
		if (!rs.IsOK()){
            bd = Page.GetResponseXml("unsucc", "操作失败!" + rs.GetErrorinfo());
			return bd;
		}
		String password = rs.GetStringTName("password");
		if (password != opass){
            bd = Page.GetResponseXml("unsucc", "操作失败!输入的原密码不正确!");
			return bd;
		}
		
		rs = Tpp.RPC.EmployeeControl.Employee.Update("password" , npass , "emp_id", emp_id);
        if (rs.IsOK()){
			bd = Page.GetResponseXml("succ");
        }else{
            bd = Page.GetResponseXml("unsucc", "操作失败!" + rs.GetErrorinfo());
        }
        return bd;
	
	}

}
	

	
