import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Int "mo:base/Int";
import Iter "mo:base/Iter";

actor BookExchange {
type UserID = Nat32;
type BookID = Nat32;

type Book = {
  title : Text;
  author : Text;
  condition : Text;
  OwnerId : UserID; // Changed to UserID to match the type
  situation : Text;
};

type User = {
  name : Text;
  lastname : Text;
  Email : Text;
  Password : Text;
  Books : [Book]; // List of books associated with the user
};


  // Storage for users
  private stable var nextuser : UserID = 0;
  private stable var users : Trie.Trie<UserID, User> = Trie.empty();

  // Storage for books
  private stable var nextbook : BookID = 0;
  private stable var books : Trie.Trie<BookID, Book> = Trie.empty();

  // Function to validate email address
  // private func isValidEmail(email: Text): Bool {
  //     let atSymbol = Text.fromCode(64); // "@" character's ASCII code is 64
  //     let parts = Text.split(email, atSymbol);
  //     if (List.length(parts) == 2) {
  //         let domainCharList = Text.toList(List.nth(parts, 1));
  //         let domain = Text.fromCode(domainCharList);
  //         return Text.equal(domain, "gmail.com");
  //     } else {
  //         return false;
  //     }
  // };

  private func key(x : UserID) : Trie.Key<UserID> {
    {
      hash = x;
      key = x;
    };
  };

  // Function for user registration/update
  public func registerOrUpdateUser(user : User) : async UserID {
    let userId = nextuser;
    nextuser += 1; // Incrementing the next available user ID
    users := Trie.replace(
      users,
      key(userId),
      Nat32.equal,
      ?user,
    ).0;
    userId;
  };

  // login with mail and passsword
  public query func LoginwithEmailandPassword(email : Text, password : Text) : async ?User {
    var userCount : Nat = Trie.size(users);
    var userCount32 : Nat32 = Nat32.fromNat(userCount);
    var userId : Nat32 = 0;
    // let mutable result: ?User = null;
    while (userId <= userCount32) {
      let currentUser = Trie.find(users, key(userId), Nat32.equal);
      switch (currentUser) {
        case (?user) {
          if (user.Email == email and user.Password == password) {
            return ?user; // Found the user, return it
          };
        };
        case null {
          // User not found, continue searching
        };
      };
      userId += 1;
    };
    null; // User not found
  };

 // Function to add a book to the system
  public func addBook(book : Book, userId: UserID) : async BookID {
    let bookId = nextbook;
    nextbook += 1; // Incrementing the next available book ID
    
    // Create a new Book object with the provided book details and userId
    let newBook = {
        title = book.title;
        author = book.author;
        condition = book.condition;
        OwnerId = userId;
        situation = book.situation;
    };
    
    // Add the new book to the storage
    books := Trie.replace(
        books,
        key(bookId),
        Nat32.equal,
        ?newBook,
    ).0;

    // Update the user's Books list with the newly added book
    // users := Trie.find(users, key(userId), Nat32.equal);
    //  user.Books := Array.append(user.Books, [newBook]);
let result = Trie.find(users, key(userId), Nat32.equal);
switch (result) {
  case (?user) {
    // User found, update their Books list
    let updatedUser = {
      user with
      Books = Array.append(user.Books, [newBook]);
    };
     users := Trie.replace(users, key(userId), Nat32.equal, ?updatedUser).0;
  };
  case null {
    // User not found
  };
};



    bookId; // Return the ID of the newly added book
  };
// function bring all the added books
public query func getAllBooks(): async [(BookID, Book)] {
  // change trie to Array and return it
    let bookPairs: [(BookID, Book)] = Iter.toArray(Trie.iter(books));
    return bookPairs
};

// Function to initiate a book exchange request
public func initiateExchange(bookId: BookID, requestingUserId: UserID): async Bool {
    // Retrieve the book from the storage
    let maybeBook = Trie.find(books, key(bookId), Nat32.equal);
    switch (maybeBook) {
        case (?book) {
            // Book found, check if the requesting user is not the OwnerId
            if (book.OwnerId != requestingUserId) {
                // send a notification to the book OwnerId
                return true; // Exchange initiated successfully
            } else {
                return false; // Requesting user is the OwnerId of the book
            }
        };
        case null {
            // Book not found
            return false;
        };
    };
};

// Function to confirm exchange and update book status
public func confirmExchange(bookId: BookID, newCondition: Text, newOwner: UserID): async Bool {
    // Retrieve the book from the storage
    let maybeBook = Trie.find(books, key(bookId), Nat32.equal);
    switch (maybeBook) {
        case (?book) {
            // Book found, update its condition and OwnerId
            let updatedBook = {
                title = book.title;
                author = book.author;
                condition = newCondition;
                OwnerId = newOwner;
                situation = book.situation; // Assuming you don't want to update situation
            };
            // Update the book in the storage
            books := Trie.replace(
                books,
                key(bookId),
                Nat32.equal,
                ?updatedBook,
            ).0;
            return true; // Exchange confirmed and book updated successfully
        };
        case null {
            // Book not found
            return false;
        };
    };
};



};
