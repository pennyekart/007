import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useToast } from '@/hooks/use-toast';

interface Registration {
  id: string;
  full_name: string;
  mobile_number: string;
  whatsapp_number: string;
  address: string;
  panchayath_details: string;
  category: string;
  status: 'pending' | 'approved' | 'rejected';
  submitted_at: string;
  approved_at?: string;
  unique_id?: string;
  user_id?: string;
}

interface Category {
  id: string;
  name: string;
  label: string;
  actual_fee: number;
  offer_fee: number;
  has_offer: boolean;
  image_url?: string;
}

interface Panchayath {
  id: string;
  malayalam_name: string;
  english_name: string;
  pincode?: string;
  district: string;
}

interface Announcement {
  id: string;
  title: string;
  content: string;
  link?: string;
  category?: string;
  is_active: boolean;
  created_at: string;
}

interface PhotoGalleryItem {
  id: string;
  title: string;
  image_url: string;
  description?: string;
  category: string;
  uploaded_at: string;
}

interface PushNotification {
  id: string;
  title: string;
  content: string;
  target_audience: 'all' | 'category' | 'panchayath' | 'admin';
  target_value?: string;
  scheduled_at?: string;
  sent_at?: string;
  is_active: boolean;
  created_at: string;
}

export const useSupabaseData = () => {
  const [registrations, setRegistrations] = useState<Registration[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [panchayaths, setPanchayaths] = useState<Panchayath[]>([]);
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [photoGallery, setPhotoGallery] = useState<PhotoGalleryItem[]>([]);
  const [notifications, setNotifications] = useState<PushNotification[]>([]);
  const [loading, setLoading] = useState(true);
  
  const { toast } = useToast();

  // Fetch all data
  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Fetch categories (public)
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('categories')
        .select('*')
        .order('name');
      
      if (categoriesError) throw categoriesError;
      setCategories(categoriesData || []);

      // Fetch panchayaths (public)
      const { data: panchayathsData, error: panchayathsError } = await supabase
        .from('panchayaths')
        .select('*')
        .order('malayalam_name');
      
      if (panchayathsError) throw panchayathsError;
      setPanchayaths(panchayathsData || []);

      // Fetch announcements (public - active only)
      const { data: announcementsData, error: announcementsError } = await supabase
        .from('announcements')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false });
      
      if (announcementsError) throw announcementsError;
      setAnnouncements(announcementsData || []);

      // Fetch photo gallery (public)
      const { data: galleryData, error: galleryError } = await supabase
        .from('photo_gallery')
        .select('*')
        .order('uploaded_at', { ascending: false });
      
      if (galleryError) throw galleryError;
      setPhotoGallery(galleryData || []);

      // Fetch all registrations (admin access)
      const { data: registrationsData, error: registrationsError } = await supabase
        .from('registrations')
        .select('*')
        .order('submitted_at', { ascending: false });
      
      if (registrationsError) throw registrationsError;
      setRegistrations(registrationsData || []);

      // Fetch notifications (admin access)
      const { data: notificationsData, error: notificationsError } = await supabase
        .from('push_notifications')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (notificationsError) throw notificationsError;
      // Filter and validate target_audience values
      const validNotifications = (notificationsData || []).filter(
        (notif): notif is PushNotification => 
          ['all', 'category', 'panchayath', 'admin'].includes(notif.target_audience)
      );
      setNotifications(validNotifications);

    } catch (error) {
      console.error('Error fetching data:', error);
      toast({
        title: "Error",
        description: "Failed to load data. Please try again.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  // Create registration (no authentication required)
  const createRegistration = async (registrationData: Omit<Registration, 'id' | 'submitted_at' | 'user_id'>) => {
    try {
      const { data, error } = await supabase
        .from('registrations')
        .insert([registrationData])
        .select()
        .single();

      if (error) throw error;

      toast({
        title: "Registration Submitted",
        description: "Your registration has been submitted successfully.",
      });

      await fetchData(); // Refresh data
      return data;
    } catch (error) {
      console.error('Error creating registration:', error);
      toast({
        title: "Error",
        description: "Failed to submit registration. Please try again.",
        variant: "destructive",
      });
      return null;
    }
  };

  // Update registration status (admin only)
  const updateRegistrationStatus = async (id: string, status: 'approved' | 'rejected', uniqueId?: string) => {
    try {
      const updateData: any = {
        status,
        approved_at: new Date().toISOString(),
      };

      if (uniqueId) {
        updateData.unique_id = uniqueId;
      }

      const { error } = await supabase
        .from('registrations')
        .update(updateData)
        .eq('id', id);

      if (error) throw error;

      toast({
        title: "Registration Updated",
        description: `Registration has been ${status}.`,
      });

      await fetchData(); // Refresh data
      return true;
    } catch (error) {
      console.error('Error updating registration:', error);
      toast({
        title: "Error",
        description: "Failed to update registration. Please try again.",
        variant: "destructive",
      });
      return false;
    }
  };

  // Delete registration (admin only)
  const deleteRegistration = async (id: string) => {
    try {
      const { error } = await supabase
        .from('registrations')
        .delete()
        .eq('id', id);

      if (error) throw error;

      toast({
        title: "Registration Deleted",
        description: "Registration has been deleted successfully.",
      });

      await fetchData(); // Refresh data
      return true;
    } catch (error) {
      console.error('Error deleting registration:', error);
      toast({
        title: "Error",
        description: "Failed to delete registration. Please try again.",
        variant: "destructive",
      });
      return false;
    }
  };

  // Update category image (admin only)
  const updateCategoryImage = async (categoryName: string, imageUrl: string) => {
    try {
      const { error } = await supabase
        .from('categories')
        .update({ image_url: imageUrl })
        .eq('name', categoryName);

      if (error) throw error;

      toast({
        title: "Category Updated",
        description: "Category image has been updated successfully.",
      });

      await fetchData(); // Refresh data
      return true;
    } catch (error) {
      console.error('Error updating category image:', error);
      toast({
        title: "Error",
        description: "Failed to update category image. Please try again.",
        variant: "destructive",
      });
      return false;
    }
  };

  // Update category fees (admin only)
  const updateCategoryFees = async (categoryName: string, actualFee: number, offerFee: number, hasOffer: boolean) => {
    try {
      const { error } = await supabase
        .from('categories')
        .update({ 
          actual_fee: actualFee,
          offer_fee: offerFee,
          has_offer: hasOffer
        })
        .eq('name', categoryName);

      if (error) throw error;

      toast({
        title: "Category Updated",
        description: "Category fees have been updated successfully.",
      });

      await fetchData(); // Refresh data
      return true;
    } catch (error) {
      console.error('Error updating category fees:', error);
      toast({
        title: "Error",
        description: "Failed to update category fees. Please try again.",
        variant: "destructive",
      });
      return false;
    }
  };

  return {
    registrations,
    categories,
    panchayaths,
    announcements,
    photoGallery,
    notifications,
    loading,
    createRegistration,
    updateRegistrationStatus,
    deleteRegistration,
    updateCategoryImage,
    updateCategoryFees,
    refreshData: fetchData,
  };
};