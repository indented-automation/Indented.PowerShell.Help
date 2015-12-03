using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Xml.Linq;

namespace Indented
{
  namespace PowerShell
  {
    namespace Help
    {
      public class DocumentItem
      {
        #region Fields
        String      name;
        String      itemName;
        Hashtable   properties = new Hashtable();
        CommandInfo commandInfo;
        XElement    xElement;
        XNamespace  command;
        XNamespace  dev;
        XNamespace  maml;
        #endregion
        
        #region Constructors
        public DocumentItem(String itemName, CommandInfo commandInfo, XElement xElement)
        {
          this.name = commandInfo.Name;
          this.itemName = itemName;
          this.commandInfo = commandInfo;
          this.xElement = xElement;
          
          GetProperties();
        }

        public DocumentItem(String itemName, Object Object, XElement xElement)
        {
          this.itemName = itemName;
          this.xElement = xElement;
          
          GetProperties();
        }

        public DocumentItem(String itemName, XElement xElement)
        {
          this.itemName = itemName;
          this.xElement = xElement; 

          GetProperties();
        }
        #endregion
        
        #region Properties
        public String Name
        {
          get { return name; } 
        }
        
        public String Item
        {
          get {
            if (itemName.IndexOf("\\") != -1)
            {
              return itemName.Substring(0, (itemName.IndexOf("\\")));
            }
            else if (itemName.IndexOf("//") != -1)
            {
              return itemName.Substring(0, (itemName.IndexOf("//")));
            }
            else
            {
              return itemName; 
            }
          }
        }
        
        public String ItemName
        {
          get { return itemName; }
          set { itemName = value; } 
        }
        
        public Hashtable Properties
        {
          get { return properties; }
        }
        
        public CommandInfo CommandInfo
        {
          get { return commandInfo; } 
        }
        
        public XElement XElement
        {
          get { return xElement; } 
        }
        #endregion
        
        #region Methods        
        private void GetProperties()
        {
            command = xElement.GetNamespaceOfPrefix("command");
            dev = xElement.GetNamespaceOfPrefix("dev");
            maml = xElement.GetNamespaceOfPrefix("maml");
             
            switch (Item)
            {
                case "Details":
                    GetPropertiesFromDetails();
                    break;
                case "Description":
                    GetPropertiesFromParagraph();
                    break;
                case "Example":
                    GetPropertiesFromExample();
                    itemName = String.Format(@"Example\{0}", properties["title"]);
                    break;
                case "Inputs":
                    GetPropertiesFromIOType();
                    itemName = String.Format(@"Inputs\{0}", properties["name"]);
                    break;
                case "Links":
                    GetPropertiesFromLinks();
                    itemName = String.Format(@"Links\{0}", properties["linkText"]);
                    break;
                case "Notes":
                    GetPropertiesFromParagraph();
                    break;
                case "Outputs":
                    GetPropertiesFromIOType();
                    itemName = String.Format(@"Outputs\{0}", properties["name"]);
                    break;
                case "Parameter":
                    GetPropertiesFromParameter();
                    itemName = String.Format(@"Parameter\{0}", properties["name"]);
                    break;
                case "Synopsis":
                    GetPropertiesFromParagraph();
                    break;
                case "Syntax":
                    GetPropertiesFromParameter();
                    break;
            }
        }
        
        private void GetPropertiesFromDetails()
        {
            properties.Add("name", xElement.Element(command + "name").Value);
            properties.Add("verb", xElement.Element(command + "verb").Value);
            properties.Add("noun", xElement.Element(command + "noun").Value);
        }
        
        private void GetPropertiesFromParagraph()
        {
            properties.Add("paragraphs", xElement.Descendants(maml + "para").Select( e => e.Value.ToString() ));
        }
        
        private void GetPropertiesFromExample()
        {
            properties.Add("title",   xElement.Element(maml + "title").Value.ToString());
            properties.Add("code",    xElement.Element(dev + "code").Value.ToString());
            properties.Add("remarks", xElement.Element(dev + "remarks").Elements(maml + "para").Select( e => e.Value.ToString() ).ToList());
        }

        private void GetPropertiesFromIOType()
        {
            properties.Add("name",        xElement.Element(dev + "type").Element(maml + "name").Value);
            GetPropertiesFromParagraph();
        }

        private void GetPropertiesFromLinks()
        {
            properties.Add("linkText", xElement.Element(maml + "linkText").Value);
            properties.Add("uri",      xElement.Element(maml + "uri").Value);
        }

        private void GetPropertiesFromParameter()
        {
            properties.Add("name",           xElement.Element(maml + "name").Value.ToString());
            // parameterValue is not populated for SwitchParameters on syntax items
            if (xElement.Elements(command + "parameterValue").Count() == 1)
            {
                properties.Add("parameterValue", xElement.Element(command + "parameterValue").Value);
            }
            properties.Add("globbing",       Boolean.Parse(xElement.Attribute("globbing").Value));
            properties.Add("pipelineInput",  xElement.Attribute("pipelineInput").Value);
            properties.Add("position",       xElement.Attribute("position").Value);
            properties.Add("required",       Boolean.Parse(xElement.Attribute("required").Value));
            properties.Add("variableLength", Boolean.Parse(xElement.Attribute("variableLength").Value));
            GetPropertiesFromParagraph();
        }
        #endregion
      }
    }
  }
}