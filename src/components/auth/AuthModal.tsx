// src/components/auth/AuthModal.tsx
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { useState } from "react"

const AuthModal = () => {
  const [open, setOpen] = useState(false)

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Login</DialogTitle>
        </DialogHeader>
        {/* Insert login form here */}
        <p>This is the auth modal. Add your form inside here.</p>
      </DialogContent>
    </Dialog>
  )
}

export default AuthModal
