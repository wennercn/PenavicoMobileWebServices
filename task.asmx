<%@ WebService Language="C#"  Class="Task" %>
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.IO;
using System.Data;
using PENAVICO;

/// <summary>
///Task 个人信息
/// </summary>
[WebService(Namespace = "http://www.wztnet.com")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class Task : System.Web.Services.WebService{
    public Task(){
	}

//获取任务列表
    [WebMethod(EnableSession = true, Description = "获取任务列表")]
    public XmlDataDocument GetTasks(){
        XmlDataDocument xd = new XmlDataDocument();

        ATLDATALib.IDBDataAtl rs = Tpp.RPC.ShipPlanControl.GetPlanShipForRoleList();
        if (rs.IsOK()){
            xd = Page.GetResponseXml("succ", "提示", "<data>"+rs.GetNamedXML()+"</data>");
        }else {
            xd = Page.GetResponseXml("unsucc", rs.GetErrorinfo());        
        }
        return xd;
    }

//业务员确认完成
    [WebMethod(EnableSession = true, Description = "业务员确认完成")]
    public XmlDataDocument CompleteTask(String data){
        XmlDataDocument bd = new XmlDataDocument();
		String datas = "";

		//获取XML对象		
		XmlDataDocument xd = new XmlDataDocument();
		xd.LoadXml(HttpUtility.UrlDecode(data));

		//保存临时文件
		String bakfile = HttpContext.Current.Server.MapPath("../../docs/temps/fiveplan_complete.xml");
		xd.Save(bakfile);
		
		if (data.Length >0){
			results items = Common.Xml2AtlData(data);
			if (!items.isok) return Page.GetResponseXml("unsucc" , items.data);
			datas = items.data;
		}

		ATLDATALib.IDBDataAtl rs;
		rs = Tpp.RPC.StartStandControl.YWYConfirmClose(
			"items" , datas , 
			"emp_id" , HttpContext.Current.Session["Member_Id"]
		);
		if (rs.IsOK()) {
			bd = Page.GetResponseXml("succ" , "成功" ,  "<data>" + rs.GetNamedXML() + "</data>");
		} else {
			bd = Page.GetResponseXml("unsucc" , " 操作失败!" + rs.GetErrorinfo());
		}
        return bd;
    }


}
	

	
