import { Component } from '@angular/core';

@Component({
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: [] // Elimina la referencia al archivo CSS
})
export class ChatComponent {
    messageInput:string = '';

     constructor(){
    }

     goBack(): void {
     console.log("going back")
    }
    selectOption(option: string): void {
    console.log("Selected option:", option);
  }
     sendMessage(): void {
    console.log("sending message:", this.messageInput);
        this.messageInput = '';
    }
}
