public class ProfileWrapper
{
    public String Label {get; set;}
    public String ProfileName {get; set;}
    public Boolean Visiabled {get; set;}
    public Boolean ReadOnly {get; set;}

    public ProfileWrapper(String profileName, String labelName, Boolean visiabled)
    {
        this.Label = labelName;
        this.ProfileName = profileName;
        this.Visiabled = visiabled;
        ReadOnly = false;
    }
}