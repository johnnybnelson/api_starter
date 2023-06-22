//NewEditCompanies functional component called from the 
//companies component. This component is either activated
//by the link /companies/new or /companies/:companyId. When
//passed with a companyId, it will also include a company
//record from the state. This company record does not get 
//passed back to companies.jsx component. This component 
//will let the user edit/save an existing company record
//using API calls, but also create a new record.
//
import React, { useState, useEffect } from "react";
import { useParams, useNavigate, useLocation } from "react-router-dom";
import * as techCompaniesService from "../../services/techCompaniesService";
import Toastr from "toastr";

function NewEditCompanies() {

  //Init the useNavigate hook
  //
  const navigate = useNavigate();

  //Init the useLocation hook
  //only grab the state hook 
  //from the location object
  //
  const { state } = useLocation();

  //Init the useParams hook and 
  //only grab the companyId
  //
  const { companyId } = useParams();

  //Build the framework for the state
  //This JSON outline is exactly how a 
  //company record is defined by the 
  //Sabio API page. An render with a 
  //payload will overwrite this base
  //outline.
  //
  const [company, setCompany] = useState({
    "id": companyId,
    "slug": "",
    "statusId": "",
    "name": "",
    "headline": "",
    "profile": "",
    "summary": "",
    "entityTypeId": 0,
    "contactInformation": {
      "id": 0,
      "entityId": 0,
      "data": "",
      "dateCreated": "",
      "dateModified": ""
    },
    "images": [
      {
        "id": 0,
        "entityId": 0,
        "imageTypeId": "Main",
        "imageUrl": ""
      }
    ],
    "urls": [
      {
        "id": 0,
        "entityId": 0,
        "url": ""
      }
    ],
    "friends": null,
    "tags": [
      {
        "id": 0,
        "entityId": 0,
        "tagName": ""
      }
    ],
    "dateCreated": "",
    "dateModified": ""
  });


  //populate the state with the companies object
  //provided by either the API call or the state
  //object passed from the companies.jsx component
  //Parameters:
  //- companyObject - A company object
  //
  const populateCompanieState = (companyObject) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setCompany((prevCompany) => {

      //Get a copy of the previous state
      //
      let pageDataComp = { ...prevCompany };

      //Overwrite that with the company object
      //this step really isn't necessary
      //
      pageDataComp = companyObject;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  }

  //Form field function to change state with
  //every onChange with the input HTML elements.
  //This was copied and modified from the Sabio
  //Wiki example.
  //Parameters:
  //- e - Event object
  // 
  const onFormFieldChange = (e) => {   //captures this event

    //Assign the target of the event to the target variable
    //
    const target = e.target;

    //This is the value to update the state with
    //
    const value = target.value;

    //This is the name of the target. Your HTML elements
    //MUST have the name property set for this to work.
    //
    const name = target.name;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setCompany(prevCompany => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevCompany
      };

      //change the value of the copied object using the name and using bracket notation
      //ONE conditional is the image, which doesn't sit at the same level with the other 
      //properties of the JSON
      //
      if (name === "imageUrl") {
        newUserObject.images[0].imageUrl = value;  //  <- not bracket notation!!!!
      } else if (name === "contact") {
        newUserObject.contactInformation.data = value;  //  <- not bracket notation!!!!
      } else if (name === "url") {
        newUserObject.urls[0].url = value;  //  <- not bracket notation!!!!
      }
      else {
        newUserObject[name] = value;  //  <- bracket notation!!!!
      }

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };


  //Invoked following mount
  //This function either grabs the company object
  //from the passed state or using an API call
  //Parameters:
  //- thiscompany - This is the existing state
  //  object with the companyId at a minimum
  //- passedState = This is the state object
  //  (or not). It is either populated or null.
  //
  const getCompany = (thisCompany, passedState) => {

    //if a state was actually passed
    //use it to populate the form.
    //
    if (passedState) {
      populateCompanieState(passedState);
    }
    //If a state object is not provided, 
    //perform the API call using the ID
    //
    else {
      techCompaniesService
        .getById(thisCompany.id)
        .then(getSuccess)
        .catch(getError);
    }
  }


  //Successful get of company record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const getSuccess = (response) => {

    //Since this object was retrieved from the Sabio API, it will
    //not contain the type and companyUrl properties. They are 
    //added here
    //
    let companyObject = { ...response.item, type: "COMPANY_EDIT", companyUrl: "" }
    //Call to populate the input elements
    //
    populateCompanieState(companyObject);    //update the state...this re-renders and reflects on the page

    //Let the user know the records were retrieved 
    //successfully
    //
    Toastr.success("Your company is loaded!");
  }


  //Unsuccessful get of company record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const getError = (err) => {

    //Build the error string
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know the record 
    //retrieval failed
    //
    Toastr.warning(errorString);
  }


  //Build the save API payload
  //This builds the JSON for the 
  //update call to the API
  //
  const getSavePayload = () => {

    return {
      "id": company.id,
      "name": company.name,
      "profile": company.profile,
      "summary": company.summary,
      "headline": company.headline,
      "contactInformation": company.contactInformation.data,
      "slug": company.slug,
      "statusId": company.statusId,
      "images": [
        {
          "imageTypeId": company.images[0].imageTypeId,
          "imageUrl": company.images[0].imageUrl
        }
      ],
      "urls": [{
        "url":
          company.urls[0].url
      }],
      "tags": company.tags ? company.tags[0].name : [""],
      "friendIds": company.friends
    }


  }

  //Build the save API payload
  //This builds the JSON for the 
  //add call to the API
  //
  const getSubmitPayload = () => {
    return {
      "name": company.name,
      "profile": company.profile,
      "summary": company.summary,
      "headline": company.headline,
      "contactInformation": company.contactInformation.data,
      "slug": company.slug,
      "statusId": company.statusId,
      "images": [
        {
          "imageTypeId": 3,
          "imageUrl": company.images[0].imageUrl
        }
      ],
      "urls": [{
        "url":
          company.urls[0].url
      }],
      "tags": company.tags ? company.tags[0].name : [""],
      "friendIds": company.friends
    }

  }


  //Invoked on save button click
  //this initiates the save of an existing
  //company record
  //Parameters:
  //- e - The event
  //
  const onSave = (e) => {

    //This is necessary to prevent a non-use
    //error for the event object
    //
    console.log("onSave", e);

    //Make the update call to the API
    //
    techCompaniesService
      .update(company.id, getSavePayload())
      .then(saveSuccess)
      .catch(saveError);
  }

  //Successful save of company record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const saveSuccess = (response) => {

    //This is necessary to prevent a non-use
    //error for the response object
    //
    console.log("saveSuccess", response);

    //Let the user know the record 
    //save was successful
    //    
    Toastr.success("Your record has been updated!");
  }


  //Unsuccessful save of company record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const saveError = (err) => {

    //Build the error message
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know the record 
    //save failed
    //    
    Toastr.warning(errorString);
  }


  //Invoked on submit button click
  //this initiates the adding of a new
  //company record
  //Parameters:
  //- e - The event object
  //
  const onSubmit = (e) => {

    //This is necessary to prevent a non-use
    //error for the event object
    //    
    console.log("onSubmit", e);

    //Make the add call to the API
    //    
    techCompaniesService
      .add(getSubmitPayload())
      .then(submitSuccess)
      .catch(submitError);
  }


  //Successful add of company record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const submitSuccess = (response) => {

    //this toastr can run just fine on creation even
    //though the page is diverted, since the navigation
    //won't happen until after the state change, which
    //is asynchronous
    //
    Toastr.success("New company record created!<br>Feel free to edit your new company record.");

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setCompany(prevCompany => {

      //Make a copy of the previous state
      //
      const newUserObject = {
        ...prevCompany
      };

      //Add the record ID to the state, but also
      //change the type, which will allow redirect
      //uning navigate at the useEffect
      newUserObject.id = response.data.item;
      newUserObject.type = "COMPANY_ADD"; //<- since this has changed, the useEffect will invoke again
      newUserObject.companyUrl = "/companies/" + response.data.item;   //this is the next destination

      //This call will start a re-render of the component
      //
      return newUserObject;
    });
  }


  //Unsuccessful add of company record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const submitError = (err) => {

    //Build error response
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know that the add
    //failed
    //
    Toastr.warning(errorString);
  }


  //Runs after mount
  //It will re-run when the company.type 
  //changes in the state
  // 
  useEffect(() => {

    //If the type of operation we completed
    //was an "add new"
    //
    if (company.type === "COMPANY_ADD") {


      //Prepare the new state object with the correct
      //properies of type and companyUrl
      //
      const stateObj = { ...company, type: "COMPANY_EDIT", companyUrl: "" };

      //Use the existing state object companyUrl to redirect to
      //this same page, also passing the new state object.
      //This operation will display the new record in edit mode
      //
      navigate(company.companyUrl, { state: stateObj });

    } else {

      //If the type is not set to ADD
      //call the get function to populate
      //the page
      //
      if (company.id) getCompany(company, state);

    }

  }, [company.type]);  //<-useEffect watches for changes


  //Invoked on companies button click
  //navigates back to the companies page
  //Parameters:
  //- e - Event object
  //
  const goToCompanies = (e) => {

    //Prevents default operation 
    //of the event object
    //
    e.preventDefault();

    //Redirect to the companies.jsx component
    //
    navigate("/companies")
  }

  //main return for display
  //
  return (
    <React.Fragment>
      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>{company.id ? "Edit company" : "New company"}</h1>
          </div>
        </div>
        <form name="controls" id="controls">
          <p><button onClick={goToCompanies} type="button" className="btn btn-primary btn-sm m-1">Companies</button>
            <button onClick={company.id ? onSave : onSubmit} type="button" className="btn btn-primary btn-sm m-1">{company.id ? "Save" : "Submit"}</button></p>
          <input type="text" defaultValue={company.id} id="id" name="id" className="form-control d-none" readOnly />
          <label>Company Name</label>
          <input type="text" id="name" name="name" value={company.name} class="form-control" onChange={onFormFieldChange} />
          <label>Headline</label>
          <input type="text" id="headline" name="headline" value={company.headline} class="form-control" onChange={onFormFieldChange} />
          <label>Summary</label>
          <input type="text" id="summary" name="summary" value={company.summary} class="form-control" onChange={onFormFieldChange} />
          <label>Profile</label>
          <input type="text" id="profile" name="profile" value={company.profile} class="form-control" onChange={onFormFieldChange} />
          <label>Slug</label>
          <input type="text" id="slug" name="slug" value={company.slug} class="form-control" onChange={onFormFieldChange} />
          <label>Image URL</label>
          <input type="text" id="imageUrl" name="imageUrl" value={company.images[0].imageUrl} onChange={onFormFieldChange} class="form-control" />
          <label>Contact Info</label>
          <input type="text" id="contact" name="contact" value={company.contactInformation.data} onChange={onFormFieldChange} class="form-control" />
          <label>Web Site</label>
          <input type="text" id="url" name="url" value={company.urls[0].url} onChange={onFormFieldChange} class="form-control" />
          <label>Status</label>
          <select id="statusId" value={company.statusId} name="statusId" onChange={onFormFieldChange} class="form-select">
            <option value="">Select a status</option>
            <option value="Active">Active</option>
            <option value="NotSet">No status</option>
            <option value="Deleted">Deleted</option>
            <option value="Flagged">Flagged</option>
          </select>
        </form>
      </div>
    </React.Fragment>

  );
}

export default NewEditCompanies;
