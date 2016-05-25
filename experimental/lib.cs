using System;
using System.Linq;
using System.Xml.Linq;
using Indented.PowerShell.Help;

namespace Indented.PowerShell.Help
{
    public class Document
    {
        String path;
        Command[] commands;

        public Command GetHelpContent(String Name)
        {
            return commands[0];   
        }
    }
    
    public enum KeywordStyle : int
    {
        UpperCase = 1,
        LowerCase,
        PascalCase
    }
    
    public class StyleOptions
    {
        String indentString = "    ";
        Boolean isBlockComment = false;
        KeywordStyle keywordStyle = KeywordStyle.UpperCase;
    }
    
    public class Command
    {
        String description;
        Details details;
        Example[] example;
        Parameter[] syntax;
        Parameter[] parameters;
        InputType[] inputTypes;
        OutputType[] outputType;
        Link[] links;
        String notes;

        public String Name
        {
            get { return details.Name; }
        }
        public String Description
        {
            get { return description; }
            set { description = value; }
        }
        
        public String ToCommentBlock()
        {
            StyleOptions styleOptions = new StyleOptions();
            return ToCommentBlock(styleOptions);
        }
        
        public String ToCommentBlock(StyleOptions styleOptions)
        {
            return "";
        }
    }
    
    public class Details
    {
        String name;
        String synopsis;
        String copyright;
        String verb;
        String noun;
        
        public String Synopsis
        {
            get { return synopsis; }
            set { synopsis = value; }
        }
        public String Name
        {
            get { return name; }
        }
        
    }
    
    public class Parameter
    {
        String name;
        String description;
        Boolean globbing;
        String pipelineInput;
        String position;
        Boolean required;
        Boolean variableLength;
        Object defaultValue;
        Object[] possibleValues;
        Validation validation;
    }
    
    public class Validation
    {
        Int32 minCount;
        Int32 maxCount;
        Int32 minLength;
        Int32 maxLength;
        Int32 minRange;
        Int32 maxRange;
        String pattern;
    }
    
    public class InputType
    {
        String name;
        String description;
    }
    
    public class OutputType
    {
        String name;
        String description;
    }

    public class Example
    {
        String title;
        String code;
    }
    
    public class Link
    {
        Uri uri;
    }
}