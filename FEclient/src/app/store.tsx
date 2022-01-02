import { configureStore } from '@reduxjs/toolkit'

import keysReducer from "../features/keys/keysSlice";

export default configureStore({
  reducer: {
    keys: keysReducer
  }
})