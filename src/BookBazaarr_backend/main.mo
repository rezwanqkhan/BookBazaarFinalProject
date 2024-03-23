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
  // Define types
  type UserID = Nat32;
  type BookID = Nat32;
  type iid = Int;

  type Book = {
    title : Text;
    author : Text;
    condition : Text;
    owner : Text;
    situation : Text;
  };

  type User = {
    name : Text;
    lastname : Text;
    Email : Text;
    Password : Text;

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
  public func addBook(book : Book) : async BookID {
    let bookId = nextbook;
    nextbook += 1; // Incrementing the next available book ID
     books := Trie.replace(
      books,
      key(bookId),
      Nat32.equal,
      ?book,
    ).0;
    bookId;
  };

  // public query func getAllBooks() : async [Book] {
         
  // };

  // Function to initiate a book exchange request
  // public func initiateExchange(bookId: BookID, requestingUserId: UserID): async Bool {
  // };

  // Function to confirm exchange and update book status
  // public func confirmExchange(bookId: BookID, newCondition: Text, newOwner: UserID): async Bool {
  // };
};
