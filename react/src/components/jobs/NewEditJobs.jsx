//NewEditJobs functional component called from the 
//jobs component. This component is either activated
//by the link /jobs/new or /jobs/:jobId. When
//passed with a jobId, it will also include a job
//record from the state. This job record does not get 
//passed back to jobs.jsx component. This component 
//will let the user edit/save an existing job record
//using API calls, but also create a new record.
//
import React, { useState, useEffect } from "react";
import { useParams, useNavigate, useLocation } from "react-router-dom";
import * as jobsService from "../../services/jobsService";
import * as techCompaniesService from "../../services/techCompaniesService";
import Toastr from "toastr";

function NewEditJobs() {

  //Init the useNavigate hook
  //
  const navigate = useNavigate();

  //Init the useLocation hook
  //only grab the state hook 
  //from the location object
  //
  const { state } = useLocation();

  //Init the useParams hook and 
  //only grab the jobId
  //
  const { jobId } = useParams();

  //Build the framework for the state
  //This JSON outline is exactly how a 
  //job record is defined by the 
  //Sabio API page. An render with a 
  //payload will overwrite this base
  //outline.
  //
  const [job, setJob] = useState({
    "id": jobId,
    "title": "",
    "description": "",
    "summary": "",
    "pay": "",
    "entityTypeId": 0,
    "slug": "",
    "statusId": "",
    "skills": [],
    "techCompany": {
      "id": 0,
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
          "imageTypeId": "",
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
      "tags": [],
      "dateCreated": "",
      "dateModified": ""
    },
    "dateCreated": "",
    "dateModified": "",
    "type": "",
    "jobUrl": "",
    "companyList": "",
    "skillString": ""
  });


  //populate the state with the jobs object
  //provided by either the API call or the state
  //object passed from the jobs.jsx component
  //Parameters:
  //- jobObject - A job object
  //
  const populateJobState = (jobObject) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setJob((prevJob) => {

      //Get a copy of the previous state
      //
      let pageDataComp = { ...prevJob };

      //Overwrite that with the job object
      //this step really isn't necessary
      //
      pageDataComp = jobObject;
      //getCompanyOptions();  //pageDataComp.companyOptions = 
      pageDataComp.skillString = commaSepSkills(jobObject.skills);

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  }


  //gathers all company records that user created
  //and in conjunction with getCompsSuccess,
  //returns HTML <option> elements in text 
  //
  const getCompanyOptions = () => {
    techCompaniesService
      .getPage(0, 1000)
      .then(getCompsSuccess)
      .catch(getCompsFail);
  }

  //After successful get of company records,
  //create the <option> elements and update the state
  //Parameters:
  //- response - The return from the API/Axios call
  //
  const getCompsSuccess = (data) => {
    let companiesArray = data.item.pagedItems;
    let companiesString = `<option value="0">Select a Company</option>`;
    for (let index = 0; index < companiesArray.length; index++) {
      companiesString += `<option value="${companiesArray[index].id}">${companiesArray[index].name}</option>`;
    }

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setJob((prevState) => {

      //grab a copy of the previous state
      //
      const newState = { ...prevState };

      //assign generated company string
      //
      newState.companyList = companiesString;

      //This call will start a re-render of the component
      //
      return newState;
    });
  }


  //if the company list fails to load, let the
  //user know
  //
  const getCompsFail = (err) => {
    console.log("getCompsFail", err)
    Toastr.error("Could not generate the list of companies.")
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
    setJob(prevJob => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevJob
      };

      //change the value of the copied object using the name and using bracket notation
      //ONE conditional is the image, which doesn't sit at the same level with the other 
      //properties of the JSON
      //
      if (name === "company") {
        newUserObject.techCompany.id = value;  //  <- not bracket notation!!!!
      } else {
        newUserObject[name] = value;  //  <- bracket notation!!!!
      }

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };


  //Invoked following mount
  //This function either grabs the job object
  //from the passed state or using an API call
  //Parameters:
  //- thisjob - This is the existing state
  //  object with the jobId at a minimum
  //- passedState = This is the state object
  //  (or not). It is either populated or null.
  //
  const getJob = (thisJob, passedState) => {

    //if a state was actually passed
    //use it to populate the form.
    //
    if (passedState) {
      populateJobState(passedState);
    }
    //If a state object is not provided, 
    //perform the API call using the ID
    //
    else {
      jobsService
        .getById(thisJob.id)
        .then(getSuccess)
        .catch(getError);
    }
  }


  //Successful get of job record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const getSuccess = (response) => {

    //Since this object was retrieved from the Sabio API, it will
    //not contain the type and jobUrl properties. They are 
    //added here
    //
    let jobObject = { ...response.item, type: "JOB_EDIT", jobUrl: "" }
    //Call to populate the input elements
    //
    populateJobState(jobObject);    //update the state...this re-renders and reflects on the page

    //Let the user know the records were retrieved 
    //successfully
    //
    Toastr.success("Your job is loaded!");
  }


  //Unsuccessful get of job record
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
      "id": job.id,
      "title": job.title,
      "description": job.description,
      "summary": job.summary,
      "pay": job.pay,
      "slug": job.slug,
      "statusId": job.statusId,
      "techCompanyId": job.techCompany.id,
      "skills": getSkillsArray(job.skillString)
    }
  }

  //receives a comma-separated list and places
  //the skills into an array
  //Parameters:
  //- skillsString - A comma-separated list
  //
  const getSkillsArray = (skillsString) => {
    //replace comma-spaces then split into an array
    return skillsString.replace(/, /g, ",").split(",");
  }


  //Build the save API payload
  //This builds the JSON for the 
  //add call to the API
  //
  const getSubmitPayload = () => {
    return {
      "title": job.title,
      "description": job.description,
      "summary": job.summary,
      "pay": job.pay,
      "slug": job.slug,
      "statusId": job.statusId,
      "techCompanyId": job.techCompany.id,
      "skills": getSkillsArray(job.skillString)
    }
  }


  //Invoked on save button click
  //this initiates the save of an existing
  //job record
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
    jobsService
      .update(job.id, getSavePayload())
      .then(saveSuccess)
      .catch(saveError);
  }


  //Successful save of job record
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


  //Unsuccessful save of job record
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
  //job record
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
    jobsService
      .add(getSubmitPayload())
      .then(submitSuccess)
      .catch(submitError);
  }


  //Successful add of job record
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
    Toastr.success("New job record created!<br>Feel free to edit your new job record.");

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setJob(prevJob => {

      //Make a copy of the previous state
      //
      const newUserObject = {
        ...prevJob
      };

      //Add the record ID to the state, but also
      //change the type, which will allow redirect
      //uning navigate at the useEffect
      newUserObject.id = response.data.item;
      newUserObject.type = "JOB_ADD"; //<- since this has changed, the useEffect will invoke again
      newUserObject.jobUrl = "/jobs/" + response.data.item;   //this is the next destination
      //newUserObject.skillString = commaSepSkills(response.skills);

      //This call will start a re-render of the component
      //
      return newUserObject;
    });
  }


  //Unsuccessful add of job record
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
  //It will re-run when the job.type 
  //changes in the state
  // 
  useEffect(() => {

    //populate the company list
    //
    getCompanyOptions();

    //If the type of operation we completed
    //was an "add new"
    //
    if (job.type === "JOB_ADD") {


      //Prepare the new state object with the correct
      //properies of type and jobUrl
      //
      const stateObj = { ...job, type: "JOB_EDIT", jobUrl: "" };

      //Use the existing state object jobUrl to redirect to
      //this same page, also passing the new state object.
      //This operation will display the new record in edit mode
      //
      navigate(job.jobUrl, { state: stateObj });

    } else {

      //If the type is not set to ADD
      //call the get function to populate
      //the page
      //
      if (job.id) getJob(job, state);

    }

  }, [job.type]);  //<-useEffect watches for changes


  //Invoked on jobs button click
  //navigates back to the jobs page
  //Parameters:
  //- e - Event object
  //
  const goToJobs = (e) => {

    //Prevents default operation 
    //of the event object
    //
    e.preventDefault();

    //Redirect to the jobs.jsx component
    //
    navigate("/jobs")
  }


  //split the skills array into a comma-separated
  //list
  //Parameter:
  //- anArray - An array of data
  //-
  const commaSepSkills = (anArray) => {
    let aString = "";
    for (let index = 0; index < anArray.length; index++) {
      if (index === anArray.length - 1) {
        aString += anArray[index].name;
      } else {
        aString += anArray[index].name + ", ";
      }
    }
    return aString;
  }

  //main return for display
  //
  return (
    <React.Fragment>
      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>{job.id ? "Edit job" : "New job"}</h1>
          </div>
        </div>
        <form name="controls" id="controls">
          <p><button onClick={goToJobs} type="button" className="btn btn-primary btn-sm m-1">Jobs</button>
            <button onClick={job.id ? onSave : onSubmit} type="button" className="btn btn-primary btn-sm m-1">{job.id ? "Save" : "Submit"}</button></p>
          <input type="text" defaultValue={job.id} id="id" name="id" className="form-control d-none" readOnly />
          <label>Job Title</label>
          <input type="text" id="title" name="title" value={job.title} class="form-control" onChange={onFormFieldChange} />
          <label>Description</label>
          <input type="text" id="description" name="description" value={job.description} class="form-control" onChange={onFormFieldChange} />
          <label>Summary</label>
          <input type="text" id="summary" name="summary" value={job.summary} class="form-control" onChange={onFormFieldChange} />
          <label>Pay</label>
          <input type="text" id="pay" name="pay" value={job.pay} class="form-control" onChange={onFormFieldChange} />
          <label>Slug</label>
          <input type="text" id="slug" name="slug" value={job.slug} class="form-control" onChange={onFormFieldChange} />
          <label>Skills (comma-separated)</label>
          <input type="text" id="skillString" name="skillString" value={job.skillString} onChange={onFormFieldChange} class="form-control" />
          <label>Company</label>
          <select dangerouslySetInnerHTML={{ __html: job.companyList }} id="company" name="company" value={job.techCompany.id} class="form-select" onChange={onFormFieldChange}>
            {/* the above ^^^^ was required ^^^^^ because it was ^^^^^  only writing text, not HTML to the page */}
          </select>
          <label>Status</label>
          <select id="statusId" value={job.statusId} name="statusId" onChange={onFormFieldChange} class="form-select">
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

export default NewEditJobs;
