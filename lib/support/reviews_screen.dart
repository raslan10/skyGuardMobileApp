import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/models/review_model.dart';
import 'package:skyguardmobileapp/services/reviews_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewsService reviewsService = ReviewsService();

  List<ReviewModel> reviews = [];

  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController commentController =
  TextEditingController();

  int selectedRating = 5;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final data = await reviewsService.getReviews();

      if (!mounted) return;

      setState(() {
        reviews = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      AppSnackbar.error(
        context,
        ErrorHandler.handle(e),
      );
    }
  }

  Future<void> submitReview() async {
    if (nameController.text.trim().isEmpty ||
        commentController.text.trim().isEmpty) {
      AppSnackbar.error(
        context,
        'Please fill all fields',
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response =
      await reviewsService.submitReview(
        name: nameController.text.trim(),
        rating: selectedRating,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        response['message'] ??
            'Review submitted successfully',
      );

      nameController.clear();
      commentController.clear();

      await fetchReviews();
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        ErrorHandler.handle(e),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    commentController.dispose();

    super.dispose();
  }

  Widget buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rating,
            (index) => const Icon(
          Icons.star,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF007BA7),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Reviews"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      "Share Your Experience",
                      style:
                      GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller:
                      nameController,
                      decoration:
                      inputDecoration(
                        'Your Name',
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<int>(
                      value: selectedRating,
                      decoration:
                      inputDecoration(
                        'Rating',
                      ),
                      items: [1, 2, 3, 4, 5]
                          .map(
                            (e) =>
                            DropdownMenuItem(
                              value: e,
                              child: Text(
                                '$e Stars',
                              ),
                            ),
                      )
                          .toList(),
                      onChanged:
                      isSubmitting
                          ? null
                          : (value) {
                        setState(() {
                          selectedRating =
                              value ??
                                  5;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller:
                      commentController,
                      maxLines: 4,
                      decoration:
                      inputDecoration(
                        'Comment',
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width:
                      double.infinity,
                      child: ElevatedButton(
                        onPressed:
                        isSubmitting
                            ? null
                            : submitReview,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF007BA7,
                          ),
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                            color: Colors
                                .white,
                          ),
                        )
                            : Text(
                          'Submit Review',
                          style:
                          GoogleFonts.poppins(
                            color: Colors
                                .white,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: reviews.isEmpty
                ? Center(
              child: Text(
                'No reviews yet',
                style:
                GoogleFonts.poppins(
                  fontSize: 16,
                  color:
                  Colors.grey[600],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh:
              fetchReviews,
              child: ListView.builder(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                itemCount:
                reviews.length,
                itemBuilder:
                    (context, index) {
                  final review =
                  reviews[index];

                  return Card(
                    elevation: 2,
                    margin:
                    const EdgeInsets.only(
                      bottom: 14,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                        14,
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(
                              Icons.person,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  review
                                      .name,
                                  style:
                                  GoogleFonts.poppins(
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    fontSize:
                                    16,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                  6,
                                ),

                                buildStars(
                                  review
                                      .rating,
                                ),

                                const SizedBox(
                                  height:
                                  8,
                                ),

                                Text(
                                  review
                                      .comment,
                                  style:
                                  GoogleFonts.poppins(
                                    color: Colors
                                        .grey[
                                    700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}