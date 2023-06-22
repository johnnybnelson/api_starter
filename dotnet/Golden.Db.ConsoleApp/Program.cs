using Sabio.Data;
using Sabio.Models.Domain.Addresses;
using Sabio.Models.Domain.Concerts;
using Sabio.Models.Domain.Friends;
using Sabio.Models.Domain.Users;
using Sabio.Models.Requests.Addresses;
using Sabio.Models.Requests.Concerts;
using Sabio.Models.Requests.Friends;
using Sabio.Models.Requests.Users;
using Sabio.Services;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Net;

namespace Sabio.Db.ConsoleApp
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            //Here are two example connection strings. Please check with the wiki and video courses to help you pick an option
            //string connString = @"Data Source=ServerName_Or_IpAddress;Initial Catalog=DB_Name;User ID=SabioUser;Password=Sabiopass1!";

            //build my connection string
            string connString = @"Data Source=104.42.194.102;Initial Catalog=C127_sjbjohn_gmail;User ID=C127_sjbjohn_gmail_User;Password=C127_sjbjohn_gmail_User25363413";

            //test the connection
            TestConnection(connString);

            //TestAddresses(connString);

            //TestUsers(connString);

            //TestFriends(connString);

            TestAssessmentOne(connString);


            Console.ReadLine();//This waits for you to hit the enter key before closing window
        }

        private static void TestAssessmentOne(string testConString)
        {
            Console.WriteLine("Testing First Assessment");

            //init provider object
            SqlDataProvider provider = new SqlDataProvider(testConString);

            //init address service
            ConcertService concertService = new ConcertService(provider);

            int concertId = 3;
            Concert firstConcert = concertService.GetById(concertId);
            Console.WriteLine(firstConcert.Name);


            List<Concert> concerts = concertService.GetAll();
            for (int i = 0; i < concerts.Count; i++)
            {
                Console.WriteLine($"Id {concerts[i].Id},Name {concerts[i].Name},Desc {concerts[i].Description},Free {concerts[i].IsFree},Address {concerts[i].Address}\n");
            }

            ConcertAddRequest addConcert = new ConcertAddRequest();
            addConcert.Name = "KISS";
            addConcert.Description = "Concert at Midnight!";
            addConcert.Cost = 100;
            addConcert.Address = "Central Park, NYC";
            addConcert.IsFree = false;
            addConcert.DateOfEvent = DateTime.Now;

            int newId = concertService.Add(addConcert);
            Console.WriteLine(newId);

            ConcertUpdateRequest updateConcert = new ConcertUpdateRequest();
            updateConcert.Id = newId;
            updateConcert.Name = "KISS 2";
            updateConcert.Description = "Concert at Midnight! 2";
            updateConcert.Cost = 0;
            updateConcert.Address = "123 Central Park, NYC";
            updateConcert.IsFree = true;
            updateConcert.DateOfEvent = DateTime.Now;

            concertService.Update(updateConcert);

            concertService.Delete(newId);


        }

        //private static void TestFriends(string testConString)
        //{
        //    Console.WriteLine("Test Friends");

        //    //init provider object
        //    SqlDataProvider provider = new SqlDataProvider(testConString);

        //    //init address service
        //    FriendService friendService = new FriendService(provider);

        //    //get one friend
        //    int getId = 40;
        //    int UserId = 4;
        //    Friend oneFriend = friendService.Get(getId);
        //    Console.WriteLine($"Title belonging to Friend ID {getId}: {oneFriend.Title}");

        //    //get all friends
        //    List<Friend> friendsAll = friendService.GetAll();
        //    Console.WriteLine("\n\nList of all friends:\n");
        //    for (int i = 0; i < friendsAll.Count; i++)
        //    {
        //        Console.WriteLine($"Id {friendsAll[i].Id},Title {friendsAll[i].Title},Bio {friendsAll[i].Bio},Summary {friendsAll[i].Summary},Headline {friendsAll[i].Headline}\n");
        //    }

        //    //Pagination(Skip until after.NET Web API task; reference this wiki)
        //    //Search  (Skip until after.NET Web API task)

        //    //Add
        //    FriendAddRequest addNewFriendRequest = new FriendAddRequest();

        //    addNewFriendRequest.Title = "Friend Title";
        //    addNewFriendRequest.Bio = "Friend Bio";
        //    addNewFriendRequest.Summary = "Friend Summary";
        //    addNewFriendRequest.Headline = "Friend Headline";
        //    addNewFriendRequest.Slug = "SLUG100002";
        //    addNewFriendRequest.StatusId = 1; 
        //    addNewFriendRequest.PrimaryImageUrl = "friend2.jpg";
        //    //addNewFriendRequest.UserId = 4;

        //    int newId = friendService.Add(addNewFriendRequest, UserId);
        //    Console.WriteLine("Id returned for user insert: " + newId.ToString());


        //    //update friend
        //    FriendUpdateRequest friendUpdateRequest = new FriendUpdateRequest();

        //    friendUpdateRequest.Id = newId;
        //    friendUpdateRequest.Title = "Friend Title updated";
        //    friendUpdateRequest.Bio = "Friend Bio updated";
        //    friendUpdateRequest.Summary = "Friend Summary updated";
        //    friendUpdateRequest.Headline = "Friend Headline updated";
        //    friendUpdateRequest.Slug = "SLUG100003";
        //    friendUpdateRequest.StatusId = 1;
        //    friendUpdateRequest.PrimaryImageUrl = "friend3.jpg";
        //    //friendUpdateRequest.UserId = 4;

        //    friendService.Update(friendUpdateRequest, UserId);
        //    Console.WriteLine("Update completed");

        //    //Delete
        //    friendService.Delete(newId);
        //    Console.WriteLine("Delete completed");

        //}

        //private static void TestUsers(string testConString)
        //{
        //    //init provider object
        //    SqlDataProvider provider = new SqlDataProvider(testConString);

        //    //init address service
        //    UserServiceV1 userService = new UserServiceV1(provider);

        //    //get one user
        //    int getId = 10;
        //    User oneUser = userService.Get(getId);
        //    Console.WriteLine($"First name belonging to userid {getId}: {oneUser.FirstName}");

        //    //get all users
        //    List<User> usersAll = userService.GetAll();
        //    Console.WriteLine("\n\nList of all users:\n");
        //    for (int i = 0; i < usersAll.Count; i++)
        //    {
        //        Console.WriteLine($"First {usersAll[i].FirstName},Last {usersAll[i].LastName},Email {usersAll[i].Email},Avatar URL {usersAll[i].AvatarUrl},Tenant Id {usersAll[i].TenantId}\n");
        //    }

        //    //get users paginated
        //    int pageIndex = 0;
        //    int pageSize = 10;
        //    List<User> usersPaginated = userService.GetPaginated(pageIndex, pageSize);
        //    Console.WriteLine($"\n\nList of all users paginated page index {pageIndex} page size {pageSize}:\n");
        //    for (int i = 0; i < usersPaginated.Count; i++)
        //    {
        //        Console.WriteLine($"First {usersPaginated[i].FirstName},Last {usersPaginated[i].LastName},Email {usersPaginated[i].Email},Avatar URL {usersPaginated[i].AvatarUrl},Tenant Id {usersPaginated[i].TenantId}\n");
        //    }

        //    //get users paginated with search
        //    pageIndex = 0;
        //    pageSize = 5;
        //    string searchThis = "Nelson";
        //    List<User> usersPaginatedSearch = userService.GetPaginatedSearch(pageIndex, pageSize, searchThis);
        //    Console.WriteLine($"\n\nList of all users with a first or last name including {searchThis}, paginated page index {pageIndex} page size {pageSize}:\n");
        //    for (int i = 0; i < usersPaginatedSearch.Count; i++)
        //    {
        //        Console.WriteLine($"First {usersPaginatedSearch[i].FirstName},Last {usersPaginatedSearch[i].LastName},Email {usersPaginatedSearch[i].Email},Avatar URL {usersPaginatedSearch[i].AvatarUrl},Tenant Id {usersPaginatedSearch[i].TenantId}\n");
        //    }


        //    //inser new user
        //    UserAddRequest addNewUserRequest = new UserAddRequest();

        //    addNewUserRequest.FirstName = "Harry";
        //    addNewUserRequest.LastName = "Winkins";
        //    addNewUserRequest.Email = "Harry.Winkins@email.com";
        //    addNewUserRequest.Password = "password126";
        //    addNewUserRequest.AvatarUrl = "harry1.jpg";
        //    addNewUserRequest.TenantId = "HARRY1002";

        //    int newId = userService.Add(addNewUserRequest);
        //    Console.WriteLine("Id returned for user insert: " + newId.ToString());

        //    //update user
        //    UserUpdateRequest userUpdateRequest = new UserUpdateRequest();

        //    userUpdateRequest.Id = newId;
        //    userUpdateRequest.FirstName = "Harry 127";
        //    userUpdateRequest.LastName = "Winkins 127";
        //    userUpdateRequest.Email = "Harry.Winkins@email.com";
        //    userUpdateRequest.Password = "password127";
        //    userUpdateRequest.AvatarUrl = "harry2.jpg";
        //    userUpdateRequest.TenantId = "HARRY1007";

        //    userService.Update(userUpdateRequest);
        //    Console.WriteLine("Update completed");

        //    //delete user
        //    //UserUpdateRequest userDeleteRequest = new UserUpdateRequest();
        //    //userDeleteRequest.Id = newId;
        //    userService.Delete(newId);
        //    Console.WriteLine("Delete completed");

        //}




        //test addresses example
        //private static void TestAddresses(string testConString)
        //{
        //    //init provider object
        //    SqlDataProvider provider = new SqlDataProvider(testConString);

        //    //init address service
        //    AddressService addressService = new AddressService(provider);

        //    //get one address - hardcoded example
        //    #region AddressGetOneRegion
        //    Address anAddress = addressService.Get(9);
        //    Console.WriteLine("Street of single 'get' with id arg: " + anAddress.LineOne);
        //    #endregion

        //    //get random 200 addresses
        //    #region AddressGet200Region
        //    List<Address> aListOfAddresses = addressService.GetRandomAddresses();

        //    Console.WriteLine("\n\nStreets of random 50 addresses:\n");
        //    for (int i = 0; i < aListOfAddresses.Count; i++)
        //    {
        //        Console.WriteLine($"{aListOfAddresses[i].LineOne},Suite {aListOfAddresses[i].SuiteNumber}, {aListOfAddresses[i].City},{aListOfAddresses[i].State} {aListOfAddresses[i].PostalCode}\n");
        //    }
        //    #endregion


        //    //insert test record
        //    #region AddressInsertRegion
        //    AddressAddRequest addRequest = new AddressAddRequest();
        //    addRequest.LineOne = "123 Random Drive";
        //    addRequest.SuiteNumber = 100;
        //    addRequest.City = "Randomtown";
        //    addRequest.State = "VA";
        //    addRequest.PostalCode = "22191";
        //    addRequest.IsActive = true;
        //    addRequest.Long = 150.000999888;
        //    addRequest.Lat = -133.22555444;

        //    int newId = addressService.Add(addRequest);
        //    Console.WriteLine("Id returned for insert: " + newId.ToString());
        //    #endregion


        //    //time for an update
        //    #region AddressUpdateRegion
        //    AddressUpdateRequest updateRequest = new AddressUpdateRequest();
        //    updateRequest.Id = newId;
        //    updateRequest.LineOne = addRequest.LineOne + "_updated";
        //    updateRequest.SuiteNumber = addRequest.SuiteNumber + 1;
        //    updateRequest.City = addRequest.City;
        //    updateRequest.State = addRequest.State;
        //    updateRequest.PostalCode = addRequest.PostalCode + 1;
        //    updateRequest.IsActive = !addRequest.IsActive;
        //    updateRequest.Long = addRequest.Long - 1;
        //    updateRequest.Lat = addRequest.Lat + 1;

        //    addressService.Update(updateRequest);
        //    Console.WriteLine("Update completed");

        //    //AddressUpdateRequest deleteAddress = new AddressUpdateRequest();
        //    //deleteAddress.Id = newId;
        //    addressService.Delete(newId);
        //    Console.WriteLine("Delete completed");

        //    #endregion
        //}

        //test connection
        private static void TestConnection(string connString)
        {
            bool isConnected = IsServerConnected(connString);
            Console.WriteLine("DB isConnected = {0}", isConnected);
        }

        //check to see if server connected
        private static bool IsServerConnected(string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
                {
                    connection.Open();
                    return true;
                }
                catch (SqlException ex)
                {
                    Console.WriteLine(ex.Message);
                    return false;
                }
            }
        }
    }
}
