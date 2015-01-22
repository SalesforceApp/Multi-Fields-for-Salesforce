@isTest
private class CreateFieldsControllerTest
{
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            return;
        }
    }

    @isTest 
    static void testAddFieldToObject() 
    {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        CreateFieldsController testController = new CreateFieldsController();
        testController.SelectedObjType = 'account';
        testController.SelectedObjType = 'account';
        System.assertEquals(22, testController.FieldTypeOptions.size());
        System.assertNotEquals(3, testController.ObjectTypeOptions.size());
        System.assertEquals(9, testController.ProfileInfos.size());

        testController.changeObjectType();
        testController.addFieldToObject();
        testController.FieldInfoList[0].Label = 'testLabel';
        testController.FieldInfoList[0].Name = 'testName';
        testController.FieldInfoList[0].Length = '44';
        testController.FieldInfoList[0].Required = false;
        List<String> layouts = new List<String>();
        layouts.add('Account-Account Layout');
        testController.FieldInfoList[0].Layouts = layouts;
        testController.submitFieldsForObject();
    }

    
}