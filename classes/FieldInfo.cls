public class FieldInfo
{
    public String Type {get; set;}
    public String Label {get; set;}
    public String Name {get; set;}
    public String Length {get; set;}
    public String HelpText {get; set;}
    public String DefaultValue {get; set;}
    public Boolean Required {get; set;}
    public List<String> Layouts {get; set;}

    public List<SelectOption> LayoutOptions {get; set;}

    public Integer FieldIndex {get; set;}
}