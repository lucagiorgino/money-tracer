// import { ComponentExample } from "@/components/component-example";

// export function App() {
// return <ComponentExample />;
// }

// export default App;

import { createBrowserRouter, Navigate, Outlet, RouterProvider } from 'react-router';

// import { Error } from './components/Error';
// import { Navigation } from './components/Navigation';
// import { SideBar } from './components/Sidebar';

import { AuthContextProvider, useAuth } from '@/hooks/useAuth';
import { ErrContextProvider } from '@/hooks/useError';
import { TransactionsPage } from '@/pages/TransactionsPage';
import { Import } from '@/pages/Import';

function Layout() {
  return (
    <>
      <ErrContextProvider>
      <AuthContextProvider>
        {/* <Navigation/>
        <Container>  
          <Row className="justify-content-between mt-5">
            <Col sm={3}>
              <SideBar />
            </Col>      
            <Col sm={9} >
              <Container className="justify-content-center" fluid>*/}
                <Outlet /> {/* 2️⃣ Render the app routes via the Layout Outlet */}
              {/* </Container>
            </Col>
          </Row>
          <Row className="fixed-bottom">
            <Col className="mx-4 mb-2"><Error/></Col>
          </Row>
        </Container> */}
      </AuthContextProvider>
      </ErrContextProvider>
    </>
  );
}

const ProtectedRoute = (props: {redirectPath: string,  children?:  React.ReactElement}) => {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    return <Navigate to={props.redirectPath} replace />;
  }

  return props.children ? props.children : <Outlet/>;
};

export const App = () => {

  const router = createBrowserRouter([  // 🆕
    { element: <Layout/>,  /* 1️⃣ Wrap your routes in a pathless layout route */
      children: [
        { path: "/", element: <div><h1>Hello!</h1></div> }, 
        // { path: "/something", Component: Login }, // redirect to keycloak? 
        { path: "/transactions", element: <TransactionsPage/>},
        { path: "/import", element: <Import/>},

        { element: <ProtectedRoute redirectPath="/" />,
          children: [
            { path: "/protected", element: 
            <div>
              <h1>Hello protected!</h1>
            </div> },
          ]
        },
      ], 
    },
    { path:"*", Component: () => <h1 className='position-absolute top-50 start-50 translate-middle'>404</h1> }
 
  ]);

  return <RouterProvider router={router} />;
}