//useState is for managing state, useEffect is for the useEffect function,
//which acts like the after mount function of class components, and
//useCallback is for currying, at least in this component
//
import React, { useState, useEffect, useCallback } from "react";   //add useCallback

import * as jobsService from "../../services/jobsService";
import Toastr from "toastr";
import Job from "../jobs/Job";
import { useNavigate } from "react-router-dom";

//PAGINATION imports
//
import Pagination from 'rc-pagination';
import 'rc-pagination/assets/index.css';
import locale from "rc-pagination/lib/locale/en_US";  //pass as prop to pagination component

function Jobs() {

  //init the useNavigate hook
  //
  const navigate = useNavigate();


  //set state framework
  //- Jobs array will contain Job objects as defined
  //  in the Sabio API Job schema.
  //- jobsComponents array will contain the returned  
  //  HTML from the Job component
  //- showContent - This is the toggle value for display
  //  of Job records. Set to false to show no Jobs
  //  at startup. Currently set to true.
  //- type - This will be either JOBS_VIEW or JOBS_EDIT.
  //  When changed from JOBS_VIEW to JOBS_EDIT, the 
  //  page will be redirected to the NewEditJobs.jsx page.
  //- editIndex - Used to indicate the index of the Jobs
  //  record to send to the NewEditJobs.jsx page.
  //- editUrl - Holds the generated URL for redirect to
  //  the NewEditJobs.jsx page. 
  //
  const [pageData, setPage] = useState({
    jobs: [],
    jobsComponents: [],
    showContent: true,     //<- change this to false to have Jobs not show on first rendering
    type: "JOBS_VIEW",
    editIndex: -1,
    editUrl: "/jobs/new",
    searchString: "",
    pageIndex: 0,
    pageSize: 12,
    totalCount: 0,
    totalPages: 0,
    modal: false
  }
  );


  //If hit the  enter key in the search text
  //field, perform a job search
  //Parameters:
  //- e - the event object
  //
  const onFormKeyUp = (e) => {

    //I put in the extra step for readability
    //
    const enterKey = 13;
    if (e.keyCode === enterKey) jobsSearch(e);
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
    setPage(prevState => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevState
      };

      // change the value of the copied object using the name and using bracket notation
      // ONE conditional is the image, which doesn't sit at the same level with the other 
      // properties of the JSON

      if (name === "imageUrl") {
        newUserObject.primaryImage.imageUrl = value;  //  <- bracket notation!!!!
      } else {
        newUserObject[name] = value;  //  <- bracket notation!!!!
      }

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };


  //populate the state with the Jobs array
  //provided by the API call
  //Parameters:
  //- jobsArray - An array of Job objects
  //
  const populateJobsState = (jobsArray) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //replace the entire Jobs array
      //
      pageDataComp.jobs = jobsArray.pagedItems;

      //Generate the HTML cards - this mapping will place
      //one Job card into each array slot
      //
      pageDataComp.jobsComponents = jobsArray.pagedItems.map(createJobCard);

      //populate pagination properties
      //
      pageDataComp.pageIndex = jobsArray.pageIndex;
      pageDataComp.pageSize = jobsArray.pageSize;
      pageDataComp.totalCount = jobsArray.totalCount;
      pageDataComp.totalPages = jobsArray.totalPages;


      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });

  };


  //Simple toggle for showing content
  //Parameters:
  //- e - This is the event object
  //
  const toggleShow = (e) => {
    e.preventDefault();
    e.stopPropagation();

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.showContent = !(prevState.showContent);

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };


  //Edit Job
  //This is invoked from the <Job> component.
  //this function updates the state and passes
  //one Job record from the Jobs array
  //within the state to the NewEditJobs.jsx.
  //Parameters:
  //- thisJob - This is a Job record from a
  //  previous state that was passed to the <Job>
  //  component. This variable is a copy that is
  //  passed back and will be used used to get the 
  //  if of the record to be edited.
  //- e - The event object pass by the <Job> component. 
  //
  const editJob = (thisJob, e) => {

    //Grab the target URL (including the id)
    //from the event
    //
    const targetPage = e.currentTarget.dataset.page;
    let buttonId = thisJob.id;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The type, editIndex, and editUrl
    //  will be the only properties updated.
    //  Updating the type will cause useEffect
    //  to re-invoke. The type changing to
    //  Job_EDIT will cause a redirect using
    //  the navigate function. See useEffect.
    //
    setPage(prevState => {

      //Get the index of the match by Job id
      //
      const idxOf = prevState.jobs.findIndex((job) => {
        let result = false;
        if (Number(job.id) === Number(buttonId)) {
          result = true;
        };
        return result;
      });

      if (!(idxOf >= 0)) return false;    //if no match, exit function

      //Get a copy of the previous state
      //
      const newState = { ...prevState };

      //Set type, index, and url
      //
      newState.type = "JOB_EDIT";      //<- editing this will cause useEffect to invoke again
      newState.editIndex = idxOf;
      newState.editUrl = targetPage;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newState;
    });
  }

  //Delete Job record
  //This example utilizes useCallback, which
  //wraps the function to keep it from 
  //re-rendering. It wasn't necessary here,
  //but I used it to test it.
  //Parameters:
  //- (arrow function) 
  //- e - event passed by <Job> component
  //
  const deleteJob = useCallback((e) => {

    let buttonId = e.target.id;
    console.log("deleting: ", buttonId);
    //Currying step 2 - invoke the function with the 
    //variable you want to be curried (id in this case)
    //This is assigned to a variable. At this point, the
    //currying function is only partially invoked
    //
    const handler = getDeleteSuccessHandler(buttonId);

    //Currying step 3 - Invoking "handler" 
    //upon success will complete the function
    //and the id will already be inside the 
    //curried function
    //
    jobsService
      .setStatus(buttonId, "2")
      .then(handler)  //<- the function that completes the currying operation
      .catch(deleteError);
  }, []);


  //Success on delete - invoked if there are no
  //errors when completing the delete using the api
  //Currying example - Step 1 - define function
  //Since the delete API call does not return
  //the ID of the deleted record, this method
  //of currying carries over the ID to be used
  //when needed.
  //See anything in code with //Currying in the 
  //comments
  //
  const getDeleteSuccessHandler = (id) => {

    //This returned function does not get executed
    //until step 3. The id will already be here 
    //from step 1
    //
    return () => {

      //Display the successful delete message via Toastr
      //
      Toastr.success("The record has been deleted!");

      //set the state
      //Parameters:
      //- An arrow function that will provide a 
      //  modifed copy of the previous state.
      // 
      setPage(prevJobs => {

        //make a copy of the previous state
        //
        const newJobsObject = {
          ...prevJobs
        };

        //Copy the Jobs as well. You must do this to
        //prevent from making changed to the existing state.
        // 
        newJobsObject.jobs = [...newJobsObject.jobs];

        //Get the index of the match by Job id
        //
        const idxOf = newJobsObject.jobs.findIndex((job) => {
          let result = false;
          if (Number(job.id) === Number(id)) {
            result = true;
          };
          return result;
        });

        //If an index was generated, remove the deleted record
        //and re-generate the HTML components
        //
        if (idxOf >= 0) {
          newJobsObject.jobs.splice(idxOf, 1);
          newJobsObject.jobsComponents = newJobsObject.jobs.map(createJobCard);
        }
        //This returned object becomes the 
        //new state. Re-render to follow.
        //
        return newJobsObject;
      });
    }
  }


  //Unsuccessfully on delete
  //This is invoked if there is an error in 
  //deleting the Job record using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const deleteError = (err) => {

    //Build an error string
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Display the error string with Toastr
    //
    Toastr.warning(errorString);
  }

  //Mapping function to build the HTML
  //for one specific Job record.
  //Provides the Job component the
  //following props:
  //- aJob.id - The Job id
  //- aJob - A copy of one Job
  //  from the Jobs array in the state.
  //- editJob - The function to edit a
  //  Job record.
  //- deleteJob - The function to delete
  //  a Job record.
  //
  const createJobCard = (aJob, index) => {
    return <Job
      key={aJob.id}
      aJob={aJob}
      editThisJob={editJob}
      deleteThisJob={deleteJob}
      index={index}
    >
    </Job>;
  };


  //Runs after mounting complete.
  //Rund every time items in the second 
  //parameter array are changed. In this
  //component, changes to pageData.type
  //will cause this function to re-run.
  // 
  useEffect(() => {

    console.log("useEffect");

    //if the type is JOB_EDIT
    //
    if (pageData.type === "JOB_EDIT") {

      //navigate to the edit page
      //
      const stateObj = { ...pageData.jobs[pageData.editIndex], type: "JOB_EDIT", jobUrl: "" };
      navigate(pageData.editUrl, { state: stateObj });

    } else if ((pageData.type === "JOBS_SEARCH_A") || (pageData.type === "JOBS_SEARCH_B")) {

      //do the search
      searchForJobs(pageData.pageIndex, pageData.pageSize, pageData.searchString);

    }
    else {

      //otherwise, get Jobs
      //
      getJobs(pageData.pageIndex, pageData.pageSize);
    }
  }, [pageData.type, pageData.pageIndex, pageData.pageSize]);
  //    ^^^^^^
  //re-run the above function if the items in the array change
  //


  //Get all Jobs from the api
  //This function is called from the 
  //useEffect function. 
  //Parameters:
  //- index - which page
  //- size - how many records per page
  //
  const getJobs = (index, size) => {
    jobsService
      .getPage(index, size)
      .then(getSuccess)
      .catch(getError);
  }


  //Successfully retrieved the Job records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const getSuccess = (data) => {

    //Since we have all the Job records, 
    //pass the array of Jobs to be processed
    //
    populateJobsState(data.item);
  }


  //Unsuccessfully gets Job records
  //This is invoked if there is an error in 
  //retrieving of the Job records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const getError = (err) => {

    //Generate the error message
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.Errors.length; i++) {
    //   errorString += err.response.data.Errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    //Let the user know there is an error using Toastr
    //
    Toastr.warning(err);
  }


  //Navigate to create a new record
  //Invoked by clicking the Create New 
  //Job button.
  //Parameters:
  //- e - Event object
  //
  const goToNew = (e) => {
    e.preventDefault();
    navigate("/jobs/new")
  }


  //Perform the search
  //Parameters:
  //- index - The base index for the paginated search
  //- size -  The size of the page
  //- searchString - The typed string to search on
  //
  const searchForJobs = (index, size, searchString) => {
    jobsService
      .search(index, size, searchString)
      .then(searchSuccess)
      .catch(searchError);
  }


  //Successfully searched the Job records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const searchSuccess = (data) => {

    //Since we have all the Job records from
    //the search, pass the array of Jobs to 
    //be processed
    //
    populateJobsState(data.item);

    //Let the user know the get was successful
    //
    //Toastr.success("Your search yielded some results!");
  }


  //Unsuccessfully searched the Job records
  //This is invoked if there is an error in 
  //retrieving of the Job records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const searchError = (err) => {

    //Generate the error message
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.errors.length; i++) {
    //   errorString += err.response.data.errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    //Let the user know there is an error using Toastr
    //
    Toastr.warning(err);
  }

  //Invoked by the search button 
  //Begins the search functionality
  //Parameters:
  //- e - Event object
  //
  const jobsSearch = (e) => {

    console.log("jobsSearch", e);
    if (!pageData.searchString) {
      Toastr.warning("Please enter a search string!");
      return;
    }

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Set type to search. Toggles between two searches, A and B
      //to allow multiple searches in a row
      //
      pageDataComp.type = (pageDataComp.type === "JOBS_SEARCH_A") ? "JOBS_SEARCH_B" : "JOBS_SEARCH_A";
      pageDataComp.pageIndex = 0;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  }

  //Clears the search text and 
  //reloads the original Jobs render
  //Parameters:
  //- e - Event object
  //
  const clearSearch = (e) => {

    console.log("clearSearch", e);

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.type = "JOBS_VIEW";
      pageDataComp.searchString = "";

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });

  }


  //Invoked by the <Pagination> component
  //with the onChange method.
  //Parameters: 
  //- page - The page of the destination in the 
  //  pagination. If i were already on page 2, 
  //  then clicked "3" or the > link, the page
  //  parameter would be 3.
  //
  const onPageChange = page => {
    console.log("onChange", page);
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.pageIndex = page - 1;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };


  //Invoked by the <Pagination> component
  //with the onChange method.
  //Parameters: 
  //- page - The page of the destination in the 
  //  pagination. If i were already on page 2, 
  //  then clicked "3" or the > link, the page
  //  parameter would be 3.
  //
  const onPageSizeChange = (e) => {
    console.log("onPageSizeChange", e);
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.pageSize = e.target.value;
      pageDataComp.pageIndex = 0;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };

  return (
    <React.Fragment>
      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>Jobs</h1>
          </div>
        </div>
        <div className="jobs row">
          <p><button onClick={toggleShow} type="button" className="btn btn-primary btn-sm m-1">Toggle Content Display</button>
            <button onClick={goToNew} type="button" className="btn btn-primary btn-sm m-1">Add New Job</button>
            <button id="clearSearch" onClick={clearSearch} className="btn btn-primary btn-sm m-1" name="clearSearch">Clear search</button>
            <button id="search" onClick={jobsSearch} className="btn btn-primary btn-sm m-1" name="search">Search</button>
            <input type="text" id="searchString" onKeyUp={onFormKeyUp} onChange={onFormFieldChange} value={pageData.searchString} name="searchString" style={{ width: "260px" }} />

          </p>

          <table className="table"><tr><td width="15%">
            <Pagination
              onChange={onPageChange}
              current={pageData.pageIndex + 1}
              total={pageData.totalCount}
              locale={locale}
              pageSize={pageData.pageSize}
            ></Pagination>

            Page Size:
            <select onChange={onPageSizeChange} value={pageData.pageSize}>
              <option value="6">6</option>
              <option value="12">12</option>
              <option value="18">18</option>
              <option value="24">24</option>
            </select>
          </td></tr></table>

          {pageData.showContent && pageData.jobsComponents}

        </div>
      </div>
    </React.Fragment>
  );
}

export default Jobs;
