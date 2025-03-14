import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 1, green: 0.42, blue: 0.42), Color(red: 0.42, green: 0.4, blue: 1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(0.85)
            
            VStack(spacing: 30) {
                // 应用图标
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .frame(width: 96, height: 96)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                }
                
                // 应用名称
                Text("私密时刻")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // 登录表单
                VStack(spacing: 20) {
                    // 用户名
                    VStack(alignment: .leading, spacing: 8) {
                        Text("用户名")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("输入用户名", text: $username)
                                .foregroundColor(.white)
                                #if os(iOS)
                                .autocapitalization(.none) // 使用旧API，更兼容
                                #endif
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    // 密码
                    VStack(alignment: .leading, spacing: 8) {
                        Text("密码")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white.opacity(0.7))
                            
                            if isPasswordVisible {
                                TextField("输入密码", text: $password)
                                    .foregroundColor(.white)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    #endif
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("输入密码", text: $password)
                                    .foregroundColor(.white)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    #endif
                                    .disableAutocorrection(true)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    // 生物识别按钮
                    Button(action: authenticateWithBiometrics) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "touchid")
                                .font(.system(size: 30))
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // 登录按钮
                    Button(action: login) {
                        Text("登录")
                            .font(.headline)
                            .foregroundColor(.pink)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    HStack {
                        Button(action: {
                            // 忘记密码
                        }) {
                            Text("忘记密码?")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // 创建账户
                        }) {
                            Text("创建账户")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                
                // 使用条款
                Text("登录即表示您同意我们的隐私政策和使用条款")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }
            .padding(.vertical, 50)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("登录错误"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
        }
    }
    
    private func login() {
        // 在实际应用中，这里应该进行真正的身份验证
        // 为了演示，我们使用一个简单的检查
        if username == "admin" && password == "password" {
            withAnimation {
                isAuthenticated = true
            }
        } else {
            alertMessage = "用户名或密码不正确"
            showingAlert = true
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        // 检查设备是否支持生物识别
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "使用生物识别进行登录"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isAuthenticated = true
                        }
                    } else {
                        alertMessage = "生物识别验证失败"
                        showingAlert = true
                    }
                }
            }
        } else {
            alertMessage = "该设备不支持生物识别"
            showingAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isAuthenticated: .constant(false))
    }
} 