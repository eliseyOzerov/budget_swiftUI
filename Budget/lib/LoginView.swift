//
//  LoginView.swift
//  Budget
//
//  Created by Elisey Ozerov on 27/11/2020.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    
    @State var showPassword = false
    
    @Namespace var heroSpace
    
    @State var splashDone = false
    var body: some View {
        Group {
            if splashDone {
                VStack() {
                    Spacer()
                    HStack(spacing: 20) {
                        Image("SplashIcon")
                            .resizable()
                            .matchedGeometryEffect(id: "splash", in: heroSpace)
                            .frame(width: 50, height: 50)
                        Text("Budget")
                            .font(.system(size: 32, weight: .bold))
                    }
                    
                    Height(60)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(BudgetTextField())
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button(action: { showPassword.toggle() }, label: {
                                Image(systemName: showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(Color.gray.opacity(0.7))
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(10)
                        .background(Color("textFieldBackground"))
                        .cornerRadius(10)
                    }
                    .frame(width: 250)
                    
                    Height(40)
                    
                    VStack(spacing: 20) {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Login")
                                .font(.headline)
                                .frame(width: 200, height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        })
                        .buttonStyle(PlainButtonStyle())
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Forgot password?")
                        })
                    }
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Register")
                    })
                }
            } else {
                Image("SplashIcon")
                    .resizable()
                    .matchedGeometryEffect(id: "splash", in: heroSpace)
                    .frame(width: 100, height: 100)
                    .offset(y: -5) // offset between launch image and this
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    splashDone = true
                }
            }
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
