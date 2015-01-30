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
    public String Scale {get; set;}
    public String VisibleLines {get; set;}

    public Boolean SortValuesForPicklist {get; set;}
    public Boolean FirstValueDefaultValueForPicklist {get; set;}
    public String PicklistValues {get; set;}

    public String ReferenceTo {get; set;}
    public String RelationshipLabel {get; set;}
    public String RelationshipName {get; set;}
}