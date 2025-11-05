import SwiftUI
import Web3Auth

struct ContentView: View {
    @StateObject var vm: ViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.isLoading {
                    ProgressView()
                } else {
                    if vm.loggedIn,let user = vm.user, let web3rpc = Web3RPC(user: user) {
                        UserDetailView(web3RPC: web3rpc, viewModel: vm)
                    } else {
                        LoginView(vm: vm)
                    }
                }
                Spacer()
            }
            .navigationTitle(vm.navigationTitle)
        }
        .onAppear {
            print("[ContentView] onAppear - loggedIn:", vm.loggedIn)
            Task {
                try await vm.setup()
            }
        }
        .onChange(of: vm.loggedIn) { newValue in
            print("[ContentView] vm.loggedIn changed:", newValue)
            print("[ContentView] vm.user is nil:", vm.user == nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vm: ViewModel())
    }
}
