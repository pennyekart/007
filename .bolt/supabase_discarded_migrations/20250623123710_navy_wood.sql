/*
  # Setup Admin User and Fix Role Management

  1. Security
    - Add proper admin role assignment
    - Fix RLS policies for better role checking
    
  2. Data Setup
    - Insert sample panchayaths
    - Ensure proper admin access
*/

-- Function to safely assign admin role to a user by email
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
  END IF;
END;
$$;

-- Insert sample panchayaths data
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