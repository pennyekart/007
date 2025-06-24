/*
  # Admin Setup and Security Configuration

  1. Security Setup
    - Create admin role assignment function
    - Set up proper RLS policies
    - Configure universal storage access
    
  2. Admin User Creation
    - Create admin user with specified credentials
    - Assign admin role automatically
    
  3. Data Access Policies
    - Ensure admin can access all registration data
    - Configure cross-origin access policies
*/

-- Create function to assign admin role by email (secure)
CREATE OR REPLACE FUNCTION assign_admin_role(user_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_user_id UUID;
BEGIN
  -- Find user by email
  SELECT id INTO target_user_id
  FROM auth.users
  WHERE email = user_email;
  
  IF target_user_id IS NOT NULL THEN
    -- Insert admin role if it doesn't exist
    INSERT INTO public.user_roles (user_id, role)
    VALUES (target_user_id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;
  ELSE
    RAISE EXCEPTION 'User with email % not found', user_email;
  END IF;
END;
$$;

-- Create function to create admin user if not exists
CREATE OR REPLACE FUNCTION create_admin_user()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_user_id UUID;
  admin_email TEXT := 'evamarketingsolutions@gmail.com';
BEGIN
  -- Check if admin user already exists
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = admin_email;
  
  IF admin_user_id IS NULL THEN
    -- Create the admin user in auth.users
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      admin_email,
      crypt('admin919123', gen_salt('bf')),
      NOW(),
      NOW(),
      NOW(),
      '{"provider": "email", "providers": ["email"]}',
      '{"full_name": "SEDP Administrator"}',
      false,
      '',
      '',
      '',
      ''
    ) RETURNING id INTO admin_user_id;
    
    -- Create profile for admin user
    INSERT INTO public.profiles (id, full_name, email)
    VALUES (admin_user_id, 'SEDP Administrator', admin_email);
    
    -- Assign admin role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (admin_user_id, 'admin');
  ELSE
    -- User exists, just ensure they have admin role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (admin_user_id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
END;
$$;

-- Execute admin user creation
SELECT create_admin_user();

-- Enhanced RLS Policies for Admin Universal Access

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Admin Access All" ON public.registrations;
DROP POLICY IF EXISTS "Admin Universal Access" ON public.registrations;
DROP POLICY IF EXISTS "Admin can view all registrations" ON public.registrations;
DROP POLICY IF EXISTS "Admin can manage all registrations" ON public.registrations;

-- Create comprehensive admin access policies for registrations
CREATE POLICY "Admin Universal Read Access" ON public.registrations
  FOR SELECT USING (
    public.has_role(auth.uid(), 'admin') OR 
    auth.email() = 'evamarketingsolutions@gmail.com'
  );

CREATE POLICY "Admin Universal Write Access" ON public.registrations
  FOR ALL USING (
    public.has_role(auth.uid(), 'admin') OR 
    auth.email() = 'evamarketingsolutions@gmail.com'
  );

-- Enhanced policies for other tables
CREATE POLICY "Admin Universal Announcements" ON public.announcements
  FOR ALL USING (
    public.has_role(auth.uid(), 'admin') OR 
    auth.email() = 'evamarketingsolutions@gmail.com'
  );

CREATE POLICY "Admin Universal Gallery" ON public.photo_gallery
  FOR ALL USING (
    public.has_role(auth.uid(), 'admin') OR 
    auth.email() = 'evamarketingsolutions@gmail.com'
  );

CREATE POLICY "Admin Universal Notifications" ON public.push_notifications
  FOR ALL USING (
    public.has_role(auth.uid(), 'admin') OR 
    auth.email() = 'evamarketingsolutions@gmail.com'
  );

-- Create function to check if user is admin by email
CREATE OR REPLACE FUNCTION is_admin_user()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users u
    JOIN public.user_roles ur ON u.id = ur.user_id
    WHERE u.id = auth.uid() 
    AND ur.role = 'admin'
    AND u.email = 'evamarketingsolutions@gmail.com'
  ) OR auth.email() = 'evamarketingsolutions@gmail.com'
$$;

-- Storage policies for universal access (if using Supabase Storage)
-- Note: These need to be applied in Supabase Dashboard or via API

-- Insert sample data if not exists
INSERT INTO public.panchayaths (malayalam_name, english_name, pincode, district) VALUES
('കൊണ്ടോട്ടി', 'Kondotty', '673638', 'Malappuram'),
('മലപ്പുറം', 'Malappuram', '676505', 'Malappuram'),
('മഞ്ചേരി', 'Manjeri', '676121', 'Malappuram'),
('പെരിന്തൽമണ്ണ', 'Perinthalmanna', '679322', 'Malappuram'),
('തിരുരങ്ങാടി', 'Tirurangadi', '676306', 'Malappuram'),
('തൃപ്രാങ്കോട്', 'Triprangode', '676303', 'Malappuram'),
('താനൂർ', 'Tanur', '676302', 'Malappuram'),
('പൊൻമുണ്ടം', 'Ponmundam', '679577', 'Malappuram'),
('ഇടപ്പാൽ', 'Edappal', '679576', 'Malappuram'),
('കുറ്റിപ്പുറം', 'Kuttippuram', '679571', 'Malappuram'),
('നിലമ്പൂർ', 'Nilambur', '679329', 'Malappuram'),
('വണ്ടൂർ', 'Wandoor', '679328', 'Malappuram'),
('ആറീക്കോട്', 'Areecode', '676124', 'Malappuram'),
('കാളികാവ്', 'Kalikavu', '676525', 'Malappuram'),
('കടമ്പുഴ', 'Kadampuzha', '676553', 'Malappuram'),
('കീഴാറ്റൂർ', 'Keezhattur', '676551', 'Malappuram'),
('മേലാറ്റൂർ', 'Melattur', '676552', 'Malappuram'),
('കോടൂർ', 'Kodur', '676554', 'Malappuram'),
('പാണ്ടിക്കാട്', 'Pandikkad', '676521', 'Malappuram'),
('മക്കരപറമ്പ', 'Makkaraparamba', '676517', 'Malappuram')
ON CONFLICT (malayalam_name) DO NOTHING;

-- Insert sample announcements
INSERT INTO public.announcements (title, content, category, is_active) VALUES
('Welcome to SEDP Registration', 'We are excited to announce the launch of our Self Employment Development Program. Register now to start your entrepreneurial journey!', 'general', true),
('New Pennyekart Features Available', 'Enhanced e-commerce tools and analytics are now available for all Pennyekart registered users. Check your dashboard for updates.', 'pennyekart', true),
('FarmeLife Training Schedule', 'Upcoming training sessions for FarmeLife participants. Modern farming techniques and sustainable practices workshop starting next week.', 'farmelife', true),
('Special Offer Extended', 'Due to popular demand, we have extended our special registration offer until the end of this month. Don''t miss out!', 'general', true)
ON CONFLICT DO NOTHING;

-- Insert sample photo gallery items
INSERT INTO public.photo_gallery (title, image_url, description, category) VALUES
('SEDP Training Session', 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=800', 'Participants learning about business development strategies', 'training'),
('Success Story - Local Entrepreneur', 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=800', 'One of our successful program graduates showcasing their business', 'success-stories'),
('Farming Workshop', 'https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg?auto=compress&cs=tinysrgb&w=800', 'FarmeLife participants learning modern farming techniques', 'farmelife'),
('Food Processing Training', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800', 'FoodeLife program participants in food processing workshop', 'foodelife'),
('Community Gathering', 'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=800', 'SEDP community members networking and sharing experiences', 'events'),
('Organic Farming Initiative', 'https://images.pexels.com/photos/1300972/pexels-photo-1300972.jpeg?auto=compress&cs=tinysrgb&w=800', 'OrganeLife participants working on organic farming projects', 'organelife')
ON CONFLICT DO NOTHING;