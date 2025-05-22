import './App.css';
import './theme/style.css';
import {useMemo} from "react";
import BuildTheme from "./theme";
import store from "./store";
import Login from "./pages/Login";
import {routes} from "./routes/PrivateRoute";
import {BrowserRouter, Route, Routes} from "react-router-dom";
import {Provider} from "react-redux";
import {ThemeProvider} from "@mui/material";
import AppLayout from "./layouts/AppLayout";
import Install from "./pages/Install";
import AuthLayout from "./layouts/AuthLayout";

const PrivateRoutes = () => {
  return routes.map(({component: Component, ...props}, i) => {
    let element = <Component {...props}/>;

    return (
        <Route
            key={i}
            {...props}
            element={element}
        />
    )
  });
};

function App() {
  const theme = useMemo(() => BuildTheme('light'), []);

  return (
      <Provider store={store}>
        <ThemeProvider theme={theme}>
          <BrowserRouter>
            <Routes>
                <Route path="/" element={<AuthLayout/>}>
                    <Route path="/" element={<Login/>}/>
                    <Route path="/install" element={<Install/>}/>
                </Route>
              <Route path="/app" element={<AppLayout/>}>
                {PrivateRoutes()}
              </Route>
            </Routes>
          </BrowserRouter>
        </ThemeProvider>
      </Provider>
  );
}

export default App;
