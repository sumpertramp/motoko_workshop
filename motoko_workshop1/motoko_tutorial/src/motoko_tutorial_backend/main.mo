//Kullanıcak kütüphanelerin yüklenmesi

import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor Assistant {

  //Akıllı sözleşmenin içersinde yer alacak verilerin tanımlanması
  //Burada iki işlem var
  type ToDo = {
    description: Text;
    completed: Bool;
  };

  //Güvenli olması için fonksiyon içine atandı
  //Bu atamalar için doğal sayı seçildi

  func natHash(n: Nat) : Hash.Hash {
    Text.hash(Nat.toText(n))
  };

  //Mutible variable = var
  //Hatch mapten belirttiğimiz veri türündeki ısmı alıp 0'a eşitliyoruz
  //Artış yapacağımız nextId tanımladık
  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
  var nextId: Nat = 0;
  
  //Yaptığımız her şeyi bir yerde listeliyoruz
  public query func getTodos() : async[ToDo] {
    Iter.toArray(todos.vals()); //dizi haline getirmek için
    
  };

  //Current function
  //ID ToDo ataması
  //bizden önce text olarak description vermesini istiyoruz
  //Kodun içini doldurmasını istiyoruz
  //Eklediğimiz id üzerinden ilerleyen sürelerde next id yaparak bunun üzerinden gidecek
  //Her seferinde 1 artırarak kimlik numarası atayacak
  public query func addToDo(description: Text): async Nat {
    let id = nextId;
    todos.put(id, {description = description; completed = false});
    nextId += 1;
    id //Return id
  };

  // update ataması
  //Artık yeni bir şey eklemiyoruz sadece kontrol ediyoruz
  public func comleteToDo(id: Nat): async () {
    ignore do ? {
      let description = todos.get(id)!.description;
      todos.put(id, {description; completed = true});
    }
  };
  
  //Hepsinin TO DOs başlığı altında toparlanmasını sağlıyoruz
  //Tamamlandı ise çıktı olarak yanına tik atıyoruz.
  //Yapılmadı ise boş olarak çıkıyor
  public query func showToDos() : async Text {
    var output : Text = "\n____TO-DOs____\n";
    for (todo: ToDo in todos.vals()) {
      output #= "\n" # todo.description;
      if (todo.completed) {output #= " ✓"};
    };
    output #"\n"
  };

  //Yapılanları temizlemesi için update fonksiyonu oluşturduk
  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(todos, Nat.equal, natHash,
    func(_, todo) {if (todo.completed) null else ?todo});
  }
}