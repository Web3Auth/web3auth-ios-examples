import SwiftUI

struct LoginView: View {
    @StateObject var vm: ViewModel
    var body: some View {
        List {
            Button(
                action: {
                    vm.loginWithGoogle()
                },
                label: {
                    Text("Continue with Google")
                }
            )
            .disabled(vm.isAuthenticating)

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(vm: ViewModel())
    }
}
